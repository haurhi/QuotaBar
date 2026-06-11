import { AppShell } from "./shell/AppShell";
import { QuotaMonitoringPage } from "./pages/QuotaMonitoringPage";

export default function App() {
  return (
    <AppShell>
      <QuotaMonitoringPage />
    </AppShell>
  );
}
