import { invoke } from "@tauri-apps/api/core";
import { fireEvent, render, screen, waitFor } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";
import App from "../../src/App";
import { mockSettings, mockUpdateState } from "../../src/lib/tauriClient";
import type { AppState, CredentialView, ProviderDefinition } from "../../src/shared/types";

vi.mock("@tauri-apps/api/core", () => ({
  invoke: vi.fn(),
}));

function setTauriRuntime(enabled: boolean) {
  if (enabled) {
    Object.defineProperty(window, "__TAURI_INTERNALS__", {
      value: {},
      configurable: true,
    });
    return;
  }

  Reflect.deleteProperty(window, "__TAURI_INTERNALS__");
}

const claudeProvider: ProviderDefinition = {
  id: "claude",
  displayName: "Claude",
  familyName: "Anthropic",
  category: "LLM",
  planType: "Pro",
  icon: "claude",
  dashboardUrl: "https://claude.ai/settings/usage",
  supportsReauth: true,
  supportsRefresh: true,
  quotaCheckConsumesSearchQuota: false,
};

const claudeAuthorization: CredentialView = {
  id: "claude-web-pro",
  providerId: "claude",
  name: "Claude Pro Login",
  kind: "dashboardCookie",
  maskedValue: "Web login authorization saved",
  copyable: false,
  active: true,
  status: "expired",
  remainingBadgeText: "Login expired",
  quotaWindows: [],
};

function mockDesktopCommands(state: AppState) {
  vi.mocked(invoke).mockImplementation((command, args) => {
    if (command === "get_app_state") {
      return Promise.resolve(state);
    }
    if (command === "get_settings") {
      return Promise.resolve({
        ...mockSettings,
        providerOrder: ["claude"],
      });
    }
    if (command === "get_update_state") {
      return Promise.resolve(mockUpdateState);
    }
    if (command === "start_web_authorization") {
      return Promise.resolve({
        providerId: "claude",
        targetCredentialId: (args as { targetCredentialId?: string }).targetCredentialId,
        loginUrl: "https://claude.ai/settings/usage",
        message: "Ready to update Claude Pro Login",
      });
    }
    throw new Error(`Unexpected command: ${command}`);
  });
}

describe("web authorization UI shell", () => {
  afterEach(() => {
    vi.mocked(invoke).mockReset();
    setTauriRuntime(false);
  });

  it("starts reauthorization for the provider and the existing dashboard account", async () => {
    setTauriRuntime(true);
    mockDesktopCommands({
      providers: [claudeProvider],
      credentials: [claudeAuthorization],
    });

    render(<App />);
    await waitFor(() => expect(invoke).toHaveBeenCalledWith("get_app_state"));

    fireEvent.click(await screen.findByRole("button", { name: "Claude Reauthorize Claude Pro Login" }));

    await waitFor(() =>
      expect(invoke).toHaveBeenCalledWith("start_web_authorization", {
        providerId: "claude",
        targetCredentialId: "claude-web-pro",
      }),
    );
  });

  it("does not silently choose a target when multiple dashboard authorizations exist", async () => {
    setTauriRuntime(true);
    mockDesktopCommands({
      providers: [claudeProvider],
      credentials: [
        claudeAuthorization,
        {
          ...claudeAuthorization,
          id: "claude-web-max",
          name: "Claude Max Login",
        },
      ],
    });

    render(<App />);
    await waitFor(() => expect(invoke).toHaveBeenCalledWith("get_app_state"));

    fireEvent.click(await screen.findByRole("button", { name: "Claude Reauthorize choose account" }));

    await waitFor(() =>
      expect(invoke).toHaveBeenCalledWith("start_web_authorization", {
        providerId: "claude",
        targetCredentialId: undefined,
      }),
    );
  });
});
