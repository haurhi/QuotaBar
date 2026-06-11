use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "camelCase")]
pub enum UpdateStatus {
    Idle,
    Checking,
    Available,
    UpToDate,
    Error,
    NotImplemented,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
#[serde(rename_all = "camelCase")]
pub struct UpdateState {
    pub current_version: String,
    pub latest_version: Option<String>,
    pub status: UpdateStatus,
    pub release_notes: Option<String>,
    pub last_checked_at: Option<String>,
    pub error_message: Option<String>,
}

impl UpdateState {
    pub fn current() -> Self {
        Self {
            current_version: env!("CARGO_PKG_VERSION").to_string(),
            latest_version: None,
            status: UpdateStatus::UpToDate,
            release_notes: None,
            last_checked_at: None,
            error_message: None,
        }
    }

    pub fn install_not_implemented() -> Self {
        Self {
            current_version: env!("CARGO_PKG_VERSION").to_string(),
            latest_version: None,
            status: UpdateStatus::NotImplemented,
            release_notes: None,
            last_checked_at: None,
            error_message: Some("Installer integration is not implemented yet.".to_string()),
        }
    }
}
