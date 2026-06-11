use super::{
    opencode_go::OpenCodeGoProvider, ProviderClient, ProviderCredential, ProviderError,
};

fn opencode_credential() -> ProviderCredential {
    ProviderCredential::fake_api_key(
        "opencode_go",
        r#"{"cookie":"auth=opencode-auth-placeholder; oc_locale=zh","workspaceID":"wrk_placeholder","serverID":"server-placeholder","serverInstance":"server-fn:11"}"#,
    )
}

#[test]
fn opencode_fixture_parses_server_function_usage_windows() {
    let client = OpenCodeGoProvider::default();
    let snapshot = client
        .check_fixture_quota(opencode_credential())
        .expect("fixture should parse");

    assert_eq!(snapshot.provider_id, "opencode_go");
    assert_eq!(snapshot.remaining, Some(2500.0));
    assert_eq!(snapshot.limit, Some(10_000.0));
    assert_eq!(snapshot.remaining_badge_text, "5h 98% · week 50% · month 25%");
    assert_eq!(snapshot.quota_label.as_deref(), Some("subscription"));
    assert_eq!(snapshot.plan_ends_at, None);
    assert!(snapshot.reset_at.is_some());
    assert_eq!(snapshot.quota_windows.len(), 3);
    assert_eq!(snapshot.quota_windows[0].name, "5h");
    assert_eq!(snapshot.quota_windows[0].percent_remaining, Some(98.0));
    assert_eq!(snapshot.quota_windows[1].name, "week");
    assert_eq!(snapshot.quota_windows[1].percent_remaining, Some(50.0));
    assert_eq!(snapshot.quota_windows[2].name, "month");
    assert_eq!(snapshot.quota_windows[2].percent_remaining, Some(25.0));
}

#[test]
fn opencode_raw_auth_cookie_is_supported() {
    let client = OpenCodeGoProvider::default();
    let snapshot = client
        .check_fixture_quota(ProviderCredential::fake_api_key(
            "opencode_go",
            "auth=opencode-auth-placeholder; oc_locale=zh",
        ))
        .expect("raw auth cookie should be accepted");

    assert_eq!(snapshot.remaining_badge_text, "5h 98% · week 50% · month 25%");
}

#[test]
fn opencode_auth_redirect_maps_to_unauthorized() {
    let client = OpenCodeGoProvider::default();
    let error = client
        .check_auth_redirect_fixture(opencode_credential())
        .expect_err("auth redirect should fail");

    assert!(matches!(
        error,
        ProviderError::Unauthorized(message) if message.contains("OpenCode Go web login")
    ));
}

#[test]
fn opencode_missing_auth_cookie_maps_to_unauthorized() {
    let client = OpenCodeGoProvider::default();
    let error = client
        .check_fixture_quota(ProviderCredential::fake_api_key("opencode_go", "oc_locale=zh"))
        .expect_err("missing auth cookie should fail");

    assert!(matches!(
        error,
        ProviderError::Unauthorized(message) if message.contains("OpenCode Go web login")
    ));
}

#[test]
fn opencode_missing_usage_windows_maps_to_quota_unavailable() {
    let client = OpenCodeGoProvider::default();
    let error = client
        .check_missing_usage_fixture(opencode_credential())
        .expect_err("missing usage windows should fail");

    assert!(matches!(
        error,
        ProviderError::QuotaUnavailable(message) if message.contains("OpenCode Go usage")
    ));
}
