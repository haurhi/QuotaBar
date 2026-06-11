import type { ReactNode } from "react";
import { Sidebar, type AppPage } from "./Sidebar";
import type { CredentialView, ProviderDefinition, UpdateState } from "../shared/types";

interface AppShellProps {
  children?: ReactNode;
  activePage?: AppPage;
  credentials?: CredentialView[];
  onNavigate?: (page: AppPage) => void;
  providers?: ProviderDefinition[];
  updateState?: UpdateState;
  onCheckForUpdates?: () => void;
}

export function AppShell({
  children,
  activePage = "quota",
  credentials,
  onCheckForUpdates,
  onNavigate,
  providers,
  updateState,
}: AppShellProps) {
  return (
    <div className="app-shell">
      <Sidebar
        activePage={activePage}
        credentials={credentials}
        onCheckForUpdates={onCheckForUpdates}
        onNavigate={onNavigate}
        providers={providers}
        updateState={updateState}
      />
      <main className="app-main">
        {children ?? (
          <section className="app-panel">
            <h2 className="page-title">Quota Monitoring</h2>
            <p className="page-subtitle">Mock desktop shell ready for quota pages.</p>
          </section>
        )}
      </main>
    </div>
  );
}
