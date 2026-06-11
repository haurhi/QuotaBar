use super::{
    serpapi::SerpApiProvider, ProviderClient, ProviderCredential, ProviderError,
};

#[test]
fn serpapi_fixture_parses_monthly_search_snapshot() {
    let client = SerpApiProvider::default();
    let snapshot = client
        .check_fixture_quota(ProviderCredential::fake_api_key("serpapi", "serp-test"))
        .expect("fixture should parse");

    assert_eq!(snapshot.provider_id, "serpapi");
    assert_eq!(snapshot.remaining, Some(4100.0));
    assert_eq!(snapshot.limit, Some(5000.0));
    assert_eq!(snapshot.remaining_badge_text, "4100 / 5000");
    assert_eq!(snapshot.quota_label.as_deref(), Some("searches"));
    assert_eq!(snapshot.quota_windows[0].percent_remaining, Some(82.0));
}

#[test]
fn serpapi_unauthorized_fixture_maps_to_credential_error() {
    let client = SerpApiProvider::default();
    let error = client
        .check_unauthorized_fixture(ProviderCredential::fake_api_key("serpapi", "serp-test"))
        .expect_err("unauthorized fixture should fail");

    assert!(matches!(
        error,
        ProviderError::Unauthorized(message) if message.contains("Invalid API key")
    ));
}

#[test]
fn serpapi_missing_quota_fixture_maps_to_quota_unavailable() {
    let client = SerpApiProvider::default();
    let error = client
        .check_quota_unavailable_fixture(ProviderCredential::fake_api_key(
            "serpapi",
            "serp-test",
        ))
        .expect_err("missing quota fixture should fail");

    assert!(matches!(
        error,
        ProviderError::QuotaUnavailable(message) if message.contains("monthly searches")
    ));
}

#[test]
fn serpapi_network_failure_maps_to_network_error() {
    let error = SerpApiProvider::map_network_error("request timed out");

    assert!(matches!(
        error,
        ProviderError::Network(message) if message.contains("request timed out")
    ));
}
