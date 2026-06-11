import { RefreshCw } from "lucide-react";
import { mockUpdateState } from "../lib/tauriClient";
import type { UpdateState } from "../shared/types";

interface SidebarUpdateFooterProps {
  updateState?: UpdateState;
  onCheckForUpdates?: () => void;
}

export function SidebarUpdateFooter({
  updateState = mockUpdateState,
  onCheckForUpdates,
}: SidebarUpdateFooterProps) {
  return (
    <footer className="sidebar-footer">
      <div>
        <div className="sidebar-version">v{updateState.currentVersion} preview</div>
        <div className="sidebar-update-status">{updateStatusLabel(updateState)}</div>
      </div>
      <button
        className="sidebar-icon-button"
        aria-label="Check for updates"
        title="Check for updates"
        onClick={onCheckForUpdates}
      >
        <RefreshCw size={15} strokeWidth={2.2} />
      </button>
    </footer>
  );
}

function updateStatusLabel(updateState: UpdateState) {
  switch (updateState.status) {
    case "available":
      return `Update ${updateState.latestVersion ?? ""} available`.trim();
    case "checking":
      return "Checking";
    case "error":
      return updateState.errorMessage ?? "Update check failed";
    case "notImplemented":
      return "Installer pending";
    case "idle":
      return "Not checked";
    case "upToDate":
    default:
      return "Up to date";
  }
}
