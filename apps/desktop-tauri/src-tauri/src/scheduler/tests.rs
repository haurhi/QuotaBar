use crate::{
    domain::{AppSettings, ProviderDefinition, RefreshInterval},
    scheduler::refresh_scheduler::planned_refresh_jobs,
};

fn providers() -> Vec<ProviderDefinition> {
    vec![
        ProviderDefinition::new_ai_search(
            "tavily",
            "Tavily",
            "Tavily",
            "tavily",
            "https://app.tavily.com/home",
            false,
        ),
        ProviderDefinition::new_ai_search(
            "brave",
            "Brave",
            "Brave",
            "brave",
            "https://api.search.brave.com/app/dashboard",
            true,
        ),
        ProviderDefinition::new_llm(
            "claude",
            "Claude",
            "Anthropic",
            "Pro",
            "claude",
            "https://claude.ai/settings/billing",
        ),
    ]
}

#[test]
fn normal_automatic_refresh_skips_costly_providers() {
    let mut settings = AppSettings::default();
    settings.auto_refresh_interval = RefreshInterval::OneHour;
    settings.costly_refresh_interval = RefreshInterval::Off;

    let jobs = planned_refresh_jobs(&settings, &providers());
    let provider_ids = jobs
        .iter()
        .map(|job| job.provider_id.as_str())
        .collect::<Vec<_>>();

    assert_eq!(provider_ids, vec!["tavily", "claude"]);
    assert!(jobs.iter().all(|job| !job.consumes_search_quota));
}

#[test]
fn costly_automatic_refresh_is_separate_and_defaults_to_off() {
    let mut settings = AppSettings::default();
    settings.auto_refresh_interval = RefreshInterval::OneHour;

    let jobs = planned_refresh_jobs(&settings, &providers());

    assert!(!jobs.iter().any(|job| job.provider_id == "brave"));
}

#[test]
fn costly_automatic_refresh_can_schedule_costly_providers() {
    let mut settings = AppSettings::default();
    settings.auto_refresh_interval = RefreshInterval::OneHour;
    settings.costly_refresh_interval = RefreshInterval::SixHours;

    let jobs = planned_refresh_jobs(&settings, &providers());
    let brave = jobs
        .iter()
        .find(|job| job.provider_id == "brave")
        .expect("brave should be scheduled");

    assert_eq!(brave.interval, RefreshInterval::SixHours);
    assert!(brave.consumes_search_quota);
}
