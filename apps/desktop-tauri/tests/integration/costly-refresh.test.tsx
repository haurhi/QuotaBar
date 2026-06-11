import { render, screen, within } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { QuotaMonitoringPage } from "../../src/pages/QuotaMonitoringPage";
import { SettingsPage } from "../../src/pages/SettingsPage";
import { mockSettings } from "../../src/lib/tauriClient";
import type { CredentialView, ProviderDefinition } from "../../src/shared/types";

const braveProvider: ProviderDefinition = {
  id: "brave",
  displayName: "Brave",
  familyName: "Brave",
  category: "AI Search",
  icon: "brave",
  dashboardUrl: "https://api.search.brave.com/app/dashboard",
  supportsReauth: false,
  supportsRefresh: true,
  quotaCheckConsumesSearchQuota: true,
};

const braveCredential: CredentialView = {
  id: "brave-test",
  providerId: "brave",
  name: "Brave Test",
  kind: "apiKey",
  maskedValue: "BSA••••test",
  copyable: true,
  active: true,
  status: "healthy",
  remaining: 742,
  limit: 1000,
  remainingBadgeText: "742 / 1000",
  quotaWindows: [{ name: "month", percentRemaining: 74.2, resetAt: "2026-07-01T00:00:00+08:00" }],
  lastHttpStatus: 200,
};

describe("costly refresh policy", () => {
  it("shows a user-visible warning when manual refresh can spend search quota", () => {
    render(<QuotaMonitoringPage providers={[braveProvider]} credentials={[braveCredential]} />);

    expect(screen.getByText("Refresh uses one search request")).toBeInTheDocument();
  });

  it("keeps costly scheduled refresh disabled by default in settings", () => {
    render(<SettingsPage settings={mockSettings} />);

    const costlyRefresh = screen.getByLabelText("Costly refresh interval");
    expect(costlyRefresh).toHaveValue("off");
    expect(within(costlyRefresh).queryByRole("option", { name: "Every 30 minutes" })).not.toBeInTheDocument();
  });
});
