use chrono::{Duration, SecondsFormat, Utc};
use serde_json::Value;

use crate::domain::QuotaWindow;

use super::{ProviderClient, ProviderCredential, ProviderError, QuotaSnapshot};

const OPENCODE_GO_USAGE_FIXTURE: &str = r#";0x00000129;((self.$R=self.$R||{})["server-fn:11"]=[],($R=>$R[0]={mine:!0,useBalance:!1,rollingUsage:$R[1]={status:"ok",resetInSec:16946,usagePercent:2},weeklyUsage:$R[2]={status:"ok",resetInSec:547976,usagePercent:50},monthlyUsage:$R[3]={status:"ok",resetInSec:2204389,usagePercent:75}})($R["server-fn:11"]))"#;

const OPENCODE_GO_AUTH_REDIRECT_FIXTURE: &str = r#";0x00000000;location.href="/auth/authorize?redirect=%2Fworkspace%2Fwrk_placeholder""#;

const OPENCODE_GO_MISSING_USAGE_FIXTURE: &str = r#";0x00000129;((self.$R=self.$R||{})["server-fn:11"]=[],($R=>$R[0]={mine:!0,useBalance:!1})($R["server-fn:11"]))"#;

#[derive(Debug, Default)]
pub struct OpenCodeGoProvider;

impl OpenCodeGoProvider {
    pub fn check_auth_redirect_fixture(
        &self,
        credential: ProviderCredential,
    ) -> Result<QuotaSnapshot, ProviderError> {
        self.check_response_fixture(credential, OPENCODE_GO_AUTH_REDIRECT_FIXTURE)
    }

    pub fn check_missing_usage_fixture(
        &self,
        credential: ProviderCredential,
    ) -> Result<QuotaSnapshot, ProviderError> {
        self.check_response_fixture(credential, OPENCODE_GO_MISSING_USAGE_FIXTURE)
    }

    fn check_response_fixture(
        &self,
        credential: ProviderCredential,
        usage_value: &str,
    ) -> Result<QuotaSnapshot, ProviderError> {
        if credential.provider_id != self.provider_id() {
            return Err(ProviderError::Unsupported(format!(
                "credential belongs to {}",
                credential.provider_id
            )));
        }

        OpenCodeGoCredential::from_secret(&credential.secret)?;
        parse_opencode_go_usage(usage_value)
    }
}

impl ProviderClient for OpenCodeGoProvider {
    fn provider_id(&self) -> &'static str {
        "opencode_go"
    }

    fn consumes_quota_on_check(&self) -> bool {
        false
    }

    fn check_fixture_quota(
        &self,
        credential: ProviderCredential,
    ) -> Result<QuotaSnapshot, ProviderError> {
        self.check_response_fixture(credential, OPENCODE_GO_USAGE_FIXTURE)
    }
}

struct OpenCodeGoCredential;

impl OpenCodeGoCredential {
    fn from_secret(secret: &str) -> Result<Self, ProviderError> {
        let trimmed = secret.trim();
        if trimmed.is_empty() || trimmed == "{}" {
            return Err(opencode_login_required());
        }

        let cookie = serde_json::from_str::<Value>(trimmed)
            .ok()
            .and_then(|value| {
                first_string(
                    &value,
                    &[
                        "cookie",
                        "cookieHeader",
                        "dashboardCookie",
                        "dashboard_cookie",
                        "authorizationCookie",
                        "auth",
                    ],
                )
            })
            .unwrap_or_else(|| trimmed.to_string());

        if cookie.contains("auth=") {
            Ok(Self)
        } else {
            Err(opencode_login_required())
        }
    }
}

fn opencode_login_required() -> ProviderError {
    ProviderError::Unauthorized("OpenCode Go web login authorization is required".to_string())
}

fn parse_opencode_go_usage(value: &str) -> Result<QuotaSnapshot, ProviderError> {
    if value.contains("/auth/authorize") {
        return Err(opencode_login_required());
    }

    let specs = [
        ("rollingUsage", "5h"),
        ("weeklyUsage", "week"),
        ("monthlyUsage", "month"),
    ];
    let windows = specs
        .iter()
        .filter_map(|(field, name)| opencode_usage_window(value, field, name))
        .collect::<Vec<_>>();

    if windows.len() != specs.len() {
        return Err(ProviderError::QuotaUnavailable(
            "OpenCode Go usage is unavailable".to_string(),
        ));
    }

    let windows = order_windows(windows);
    let tightest_percent = windows
        .iter()
        .filter_map(|window| window.percent_remaining)
        .fold(100.0, f64::min);
    let reset_at = windows
        .iter()
        .filter(|window| window.reset_at.is_some())
        .min_by(|left, right| {
            let left_percent = left.percent_remaining.unwrap_or(100.0);
            let right_percent = right.percent_remaining.unwrap_or(100.0);
            left_percent.total_cmp(&right_percent)
        })
        .and_then(|window| window.reset_at.clone());

    Ok(QuotaSnapshot {
        provider_id: "opencode_go".to_string(),
        remaining: Some(basis_points(tightest_percent)),
        limit: Some(10_000.0),
        remaining_badge_text: windows
            .iter()
            .filter_map(|window| {
                window
                    .percent_remaining
                    .map(|percent| format!("{} {}", window.name, format_percent(percent)))
            })
            .collect::<Vec<_>>()
            .join(" · "),
        quota_label: Some("subscription".to_string()),
        quota_windows: windows,
        reset_at,
        plan_ends_at: None,
    })
}

fn opencode_usage_window(text: &str, field: &str, name: &str) -> Option<QuotaWindow> {
    let block = object_block_after_field(text, field)?;
    let usage_percent = number_after_key(&block, "usagePercent")?;
    Some(QuotaWindow {
        name: name.to_string(),
        percent_remaining: Some(round_percent((100.0 - usage_percent).max(0.0))),
        remaining_text: None,
        reset_at: number_after_key(&block, "resetInSec").and_then(reset_seconds_from_now),
    })
}

fn object_block_after_field(text: &str, field: &str) -> Option<String> {
    let field_start = text.find(field)?;
    let after_field = &text[field_start + field.len()..];
    let open_relative = after_field.find('{')?;
    let open_index = field_start + field.len() + open_relative;
    let mut depth = 0_i32;
    let mut block_start = None;

    for (relative_index, character) in text[open_index..].char_indices() {
        match character {
            '{' => {
                depth += 1;
                if block_start.is_none() {
                    block_start = Some(open_index + relative_index + character.len_utf8());
                }
            }
            '}' => {
                depth -= 1;
                if depth == 0 {
                    let start = block_start?;
                    let end = open_index + relative_index;
                    return Some(text[start..end].to_string());
                }
            }
            _ => {}
        }
    }

    None
}

fn number_after_key(block: &str, key: &str) -> Option<f64> {
    let start = block.find(key)? + key.len();
    let tail = &block[start..];
    let colon = tail.find(':')?;
    let value = tail[colon + 1..].trim_start();
    let value = value
        .chars()
        .take_while(|character| {
            character.is_ascii_digit()
                || *character == '.'
                || *character == '-'
                || *character == '+'
        })
        .collect::<String>();
    value.parse::<f64>().ok()
}

fn reset_seconds_from_now(seconds: f64) -> Option<String> {
    if seconds <= 0.0 {
        return None;
    }
    let date_time = Utc::now() + Duration::seconds(seconds.trunc() as i64);
    Some(date_time.to_rfc3339_opts(SecondsFormat::Secs, true))
}

fn order_windows(mut windows: Vec<QuotaWindow>) -> Vec<QuotaWindow> {
    windows.sort_by_key(|window| match window.name.as_str() {
        "5h" => 0,
        "week" => 1,
        "month" => 2,
        _ => 3,
    });
    windows
}

fn basis_points(percent: f64) -> f64 {
    (percent.clamp(0.0, 100.0) * 100.0).floor()
}

fn round_percent(value: f64) -> f64 {
    (value * 10.0).round() / 10.0
}

fn format_percent(value: f64) -> String {
    let rounded = round_percent(value);
    if (rounded.fract()).abs() < f64::EPSILON {
        format!("{}%", rounded as i64)
    } else {
        format!("{rounded:.1}%")
    }
}

fn first_string(value: &Value, keys: &[&str]) -> Option<String> {
    keys.iter()
        .find_map(|key| string_at(value, key))
        .filter(|value| !value.trim().is_empty())
}

fn string_at(value: &Value, key: &str) -> Option<String> {
    value.get(key).and_then(|value| {
        value
            .as_str()
            .map(ToString::to_string)
            .or_else(|| value.as_i64().map(|number| number.to_string()))
    })
}
