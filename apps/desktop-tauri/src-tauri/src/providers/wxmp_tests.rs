use super::{wxmp::WxmpProvider, ProviderClient, ProviderCredential, ProviderError};

#[test]
fn wxmp_fixture_parses_cny_balance_snapshot() {
    let client = WxmpProvider::default();
    let snapshot = client
        .check_fixture_quota(ProviderCredential::fake_api_key("wxmp", "wechat-test"))
        .expect("fixture should parse");

    assert_eq!(snapshot.provider_id, "wxmp");
    assert_eq!(snapshot.remaining, Some(161.8));
    assert_eq!(snapshot.limit, Some(161.8));
    assert_eq!(snapshot.remaining_badge_text, "¥161.80");
    assert_eq!(snapshot.quota_label.as_deref(), Some("CNY"));
    assert!(snapshot.quota_windows.is_empty());
    assert_eq!(snapshot.reset_at, None);
}

#[test]
fn wxmp_string_balance_fixture_is_supported() {
    let client = WxmpProvider::default();
    let snapshot = client
        .check_string_balance_fixture(ProviderCredential::fake_api_key("wxmp", "wechat-test"))
        .expect("string balance fixture should parse");

    assert_eq!(snapshot.remaining, Some(8.5));
    assert_eq!(snapshot.remaining_badge_text, "¥8.50");
}

#[test]
fn wxmp_unauthorized_fixture_maps_to_credential_error() {
    let client = WxmpProvider::default();
    let error = client
        .check_unauthorized_fixture(ProviderCredential::fake_api_key("wxmp", "wechat-test"))
        .expect_err("unauthorized fixture should fail");

    assert!(matches!(
        error,
        ProviderError::Unauthorized(message) if message.contains("Invalid API key")
    ));
}

#[test]
fn wxmp_missing_balance_fixture_maps_to_quota_unavailable() {
    let client = WxmpProvider::default();
    let error = client
        .check_quota_unavailable_fixture(ProviderCredential::fake_api_key(
            "wxmp",
            "wechat-test",
        ))
        .expect_err("missing balance fixture should fail");

    assert!(matches!(
        error,
        ProviderError::QuotaUnavailable(message) if message.contains("WeChat Search balance")
    ));
}

#[test]
fn wxmp_network_failure_maps_to_network_error() {
    let error = WxmpProvider::map_network_error("request timed out");

    assert!(matches!(
        error,
        ProviderError::Network(message) if message.contains("request timed out")
    ));
}
