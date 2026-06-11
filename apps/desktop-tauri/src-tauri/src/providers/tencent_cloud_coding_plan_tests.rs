use super::{
    tencent_cloud_coding_plan::TencentCloudCodingPlanProvider, ProviderClient,
    ProviderCredential, ProviderError,
};

fn tencent_credential() -> ProviderCredential {
    ProviderCredential::fake_api_key(
        "tencent_cloud_coding_plan",
        "uin=o123456789; skey=skey-placeholder; ownerUin=o123456789",
    )
}

#[test]
fn tencent_fixture_parses_describe_pkg_windows_and_plan_end() {
    let client = TencentCloudCodingPlanProvider::default();
    let snapshot = client
        .check_fixture_quota(tencent_credential())
        .expect("fixture should parse");

    assert_eq!(snapshot.provider_id, "tencent_cloud_coding_plan");
    assert_eq!(snapshot.remaining, Some(8000.0));
    assert_eq!(snapshot.limit, Some(10_000.0));
    assert_eq!(snapshot.remaining_badge_text, "5h 99% · week 90% · month 80%");
    assert_eq!(snapshot.quota_label.as_deref(), Some("subscription"));
    assert_eq!(
        snapshot.reset_at.as_deref(),
        Some("2026-06-30T16:00:00Z")
    );
    assert_eq!(
        snapshot.plan_ends_at.as_deref(),
        Some("2026-06-30T16:00:00Z")
    );
    assert_eq!(snapshot.quota_windows.len(), 3);
    assert_eq!(
        snapshot.quota_windows[0].remaining_text.as_deref(),
        Some("1188 / 1200")
    );
    assert_eq!(
        snapshot.quota_windows[1].remaining_text.as_deref(),
        Some("8100 / 9000")
    );
    assert_eq!(
        snapshot.quota_windows[2].remaining_text.as_deref(),
        Some("14400 / 18000")
    );
}

#[test]
fn tencent_zero_packages_maps_to_no_subscribed_plan() {
    let client = TencentCloudCodingPlanProvider::default();
    let error = client
        .check_no_subscription_fixture(tencent_credential())
        .expect_err("zero packages should fail");

    assert!(matches!(
        error,
        ProviderError::NoSubscribedPlan(message) if message.contains("Tencent Cloud coding plan")
    ));
}

#[test]
fn tencent_login_state_failure_maps_to_unauthorized() {
    let client = TencentCloudCodingPlanProvider::default();
    let error = client
        .check_login_failure_fixture(tencent_credential())
        .expect_err("login-state failure should fail");

    assert!(matches!(
        error,
        ProviderError::Unauthorized(message) if message.contains("Tencent Cloud web login")
    ));
}

#[test]
fn tencent_missing_dashboard_cookie_maps_to_unauthorized() {
    let client = TencentCloudCodingPlanProvider::default();
    let error = client
        .check_fixture_quota(ProviderCredential::fake_api_key(
            "tencent_cloud_coding_plan",
            "uin=o123456789",
        ))
        .expect_err("missing skey should fail");

    assert!(matches!(
        error,
        ProviderError::Unauthorized(message) if message.contains("Tencent Cloud web login")
    ));
}
