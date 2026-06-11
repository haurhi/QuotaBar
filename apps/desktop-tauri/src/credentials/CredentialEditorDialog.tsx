import { Eye, X } from "lucide-react";
import { providerRegistry } from "../shared/mockData";

interface CredentialEditorDialogProps {
  open: boolean;
  onClose: () => void;
}

export function CredentialEditorDialog({ open, onClose }: CredentialEditorDialogProps) {
  if (!open) {
    return null;
  }

  return (
    <div className="dialog-backdrop">
      <section className="credential-dialog" role="dialog" aria-label="Add Credential">
        <header className="credential-dialog-header">
          <div>
            <h2>Add Credential</h2>
            <p>Choose a provider and save the credential used by Quota Radar.</p>
          </div>
          <button aria-label="Close editor" onClick={onClose}>
            <X size={16} />
          </button>
        </header>
        <div className="credential-dialog-body">
          <aside className="credential-dialog-provider-list">
            {providerRegistry.map((provider) => (
              <button key={provider.id}>{provider.displayName}</button>
            ))}
          </aside>
          <form className="credential-dialog-form">
            <label>
              Credential name
              <input placeholder="Personal key" />
            </label>
            <label>
              API key
              <div className="secret-input">
                <input aria-label="API key" type="password" placeholder="Paste API key" />
                <button type="button" aria-label="Reveal API key">
                  <Eye size={15} />
                </button>
              </div>
            </label>
            <label>
              Web login authorization
              <textarea placeholder="Paste captured authorization data or authenticate in a later backend phase" />
            </label>
            <label>
              Note
              <input placeholder="Optional" />
            </label>
          </form>
        </div>
        <footer className="credential-dialog-footer">
          <button onClick={onClose}>Cancel</button>
          <button className="primary-button">Add</button>
        </footer>
      </section>
    </div>
  );
}
