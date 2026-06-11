use serde::Serialize;

use crate::domain::{AppSettings, ProviderDefinition, RefreshInterval};

#[derive(Debug, Clone, Serialize, PartialEq)]
#[serde(rename_all = "camelCase")]
pub struct RefreshJob {
    pub provider_id: String,
    pub interval: RefreshInterval,
    pub consumes_search_quota: bool,
}

pub fn planned_refresh_jobs(
    settings: &AppSettings,
    providers: &[ProviderDefinition],
) -> Vec<RefreshJob> {
    providers
        .iter()
        .filter(|provider| provider.hidden != Some(true))
        .filter(|provider| provider.supports_refresh)
        .filter_map(|provider| {
            if provider.quota_check_consumes_search_quota {
                return scheduled_job(provider, &settings.costly_refresh_interval);
            }

            scheduled_job(provider, &settings.auto_refresh_interval)
        })
        .collect()
}

fn scheduled_job(provider: &ProviderDefinition, interval: &RefreshInterval) -> Option<RefreshJob> {
    if matches!(interval, RefreshInterval::Off) {
        return None;
    }

    Some(RefreshJob {
        provider_id: provider.id.clone(),
        interval: interval.clone(),
        consumes_search_quota: provider.quota_check_consumes_search_quota,
    })
}
