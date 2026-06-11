use tauri::{AppHandle, Runtime};

use crate::{
    domain::{AppState, CredentialView},
    providers::registry::visible_provider_definitions,
    storage::metadata_store::{load_credentials, TauriMetadataStore},
};

#[tauri::command]
pub fn get_app_state<R: Runtime>(app: AppHandle<R>) -> Result<AppState, String> {
    let metadata_store = TauriMetadataStore::open(&app)?;
    let credentials = load_credentials(&metadata_store)?;
    Ok(app_state_from_credentials(credentials))
}

pub fn app_state_from_credentials(credentials: Vec<CredentialView>) -> AppState {
    AppState {
        providers: visible_provider_definitions(),
        credentials,
    }
}
