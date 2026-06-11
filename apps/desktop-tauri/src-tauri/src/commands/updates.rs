use crate::domain::UpdateState;

#[tauri::command]
pub fn get_update_state() -> UpdateState {
    UpdateState::current()
}

#[tauri::command]
pub fn check_for_updates() -> UpdateState {
    UpdateState::current()
}

#[tauri::command]
pub fn download_and_install_update() -> UpdateState {
    UpdateState::install_not_implemented()
}
