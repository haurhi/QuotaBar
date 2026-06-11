use crate::domain::UpdateState;

#[tauri::command]
pub fn get_update_state() -> UpdateState {
    UpdateState::packaging_pending()
}

#[tauri::command]
pub fn check_for_updates() -> UpdateState {
    UpdateState::packaging_pending()
}

#[tauri::command]
pub fn download_and_install_update() -> UpdateState {
    UpdateState::install_not_implemented()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::domain::UpdateStatus;

    #[test]
    fn update_check_is_informational_until_signed_artifacts_are_configured() {
        let state = check_for_updates();

        assert_eq!(state.status, UpdateStatus::NotImplemented);
        assert!(state
            .error_message
            .as_deref()
            .unwrap_or_default()
            .contains("signed update artifacts"));
    }

    #[test]
    fn install_command_remains_disabled_until_signed_artifacts_are_configured() {
        let state = download_and_install_update();

        assert_eq!(state.status, UpdateStatus::NotImplemented);
        assert!(state
            .error_message
            .as_deref()
            .unwrap_or_default()
            .contains("signed update artifacts"));
    }
}
