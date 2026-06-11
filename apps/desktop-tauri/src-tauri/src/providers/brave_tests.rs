use super::{brave::BraveProvider, ProviderClient, ProviderCredential};

#[test]
fn brave_provider_reports_that_quota_checks_consume_search_quota() {
    let client = BraveProvider::default();

    assert_eq!(client.provider_id(), "brave");
    assert!(client.consumes_quota_on_check());
}

#[test]
fn brave_fixture_parses_monthly_request_snapshot() {
    let client = BraveProvider::default();
    let snapshot = client
        .check_fixture_quota(ProviderCredential::fake_api_key("brave", "BSA-test"))
        .expect("fixture should parse");

    assert_eq!(snapshot.provider_id, "brave");
    assert_eq!(snapshot.remaining, Some(742.0));
    assert_eq!(snapshot.limit, Some(1000.0));
    assert_eq!(snapshot.remaining_badge_text, "742 / 1000");
    assert_eq!(snapshot.quota_windows[0].name, "month");
    assert_eq!(snapshot.quota_windows[0].percent_remaining, Some(74.2));
}
