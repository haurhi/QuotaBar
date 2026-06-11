import { useState } from "react";
import { AppShell } from "./shell/AppShell";
import type { AppPage } from "./shell/Sidebar";
import { CredentialsPage } from "./pages/CredentialsPage";
import { DiagnosticsPage } from "./pages/DiagnosticsPage";
import { QuotaMonitoringPage } from "./pages/QuotaMonitoringPage";
import { SettingsPage } from "./pages/SettingsPage";
import { TrayPopover } from "./tray/TrayPopover";

export default function App() {
  const [activePage, setActivePage] = useState<AppPage>("quota");

  if (new URLSearchParams(window.location.search).get("view") === "tray") {
    return (
      <main className="tray-preview">
        <TrayPopover />
      </main>
    );
  }

  const page = {
    quota: <QuotaMonitoringPage />,
    credentials: <CredentialsPage />,
    diagnostics: <DiagnosticsPage />,
    settings: <SettingsPage />,
  }[activePage];

  return (
    <AppShell activePage={activePage} onNavigate={setActivePage}>
      {page}
    </AppShell>
  );
}
