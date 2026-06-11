import type { ReactNode } from "react";
import { Sidebar, type AppPage } from "./Sidebar";

interface AppShellProps {
  children?: ReactNode;
  activePage?: AppPage;
  onNavigate?: (page: AppPage) => void;
}

export function AppShell({ children, activePage = "quota", onNavigate }: AppShellProps) {
  return (
    <div className="app-shell">
      <Sidebar activePage={activePage} onNavigate={onNavigate} />
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
