import { useMemo, useState } from "react";
import { Download, Plus } from "lucide-react";
import { CredentialEditorDialog } from "../credentials/CredentialEditorDialog";
import { ProviderCredentialGroup } from "../credentials/ProviderCredentialGroup";
import { mockCredentials, providerRegistry } from "../shared/mockData";

export function CredentialsPage() {
  const [editorOpen, setEditorOpen] = useState(false);
  const configuredProviders = useMemo(
    () =>
      providerRegistry
        .map((provider) => ({
          provider,
          credentials: mockCredentials.filter((credential) => credential.providerId === provider.id),
        }))
        .filter((group) => group.credentials.length > 0),
    [],
  );

  return (
    <div className="credentials-page">
      <section className="credential-action-panel">
        <div>
          <h2>Credentials</h2>
          <p>Add credentials, import environment files, and manage copy-safe API keys.</p>
          <div className="credential-kind-legend" aria-label="Credential types">
            <span>Web Login Authorization</span>
            <span>Companion API Key</span>
            <span>API Key</span>
          </div>
        </div>
        <div className="credential-action-buttons">
          <button onClick={() => setEditorOpen(true)}>
            <Plus size={15} />
            Add Credential
          </button>
          <button>
            <Download size={15} />
            Import .env
          </button>
        </div>
      </section>
      <div className="credential-provider-list">
        {configuredProviders.map((group) => (
          <ProviderCredentialGroup key={group.provider.id} provider={group.provider} credentials={group.credentials} />
        ))}
      </div>
      <CredentialEditorDialog open={editorOpen} onClose={() => setEditorOpen(false)} />
    </div>
  );
}
