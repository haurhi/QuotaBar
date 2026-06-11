import { describe, expect, it } from "vitest";
import { buildMenuSummary, buildProviderStats } from "../../src/shared/selectors";
import { mockCredentials, providerRegistry } from "../../src/shared/mockData";

describe("provider selectors", () => {
  it("hides unconfigured providers", () => {
    const stats = buildProviderStats(providerRegistry, mockCredentials);
    expect(stats.every((stat) => stat.credentials.length > 0)).toBe(true);
  });

  it("marks provider red when any active credential needs attention", () => {
    const stats = buildProviderStats(providerRegistry, mockCredentials);
    const brave = stats.find((stat) => stat.provider.id === "brave");
    expect(brave?.needsAttention).toBe(true);
  });

  it("builds tray risk summary from credential states", () => {
    const summary = buildMenuSummary(mockCredentials);
    expect(summary.failedCount).toBeGreaterThanOrEqual(1);
    expect(summary.lowCount).toBeGreaterThanOrEqual(1);
    expect(summary.availableCount).toBeGreaterThanOrEqual(1);
  });
});
