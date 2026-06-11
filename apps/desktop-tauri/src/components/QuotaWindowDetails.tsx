import type { QuotaWindow } from "../shared/types";

interface QuotaWindowDetailsProps {
  windows: QuotaWindow[];
}

export function QuotaWindowDetails({ windows }: QuotaWindowDetailsProps) {
  if (windows.length === 0) {
    return null;
  }

  return (
    <div className="quota-window-list">
      {windows.map((window) => (
        <span key={`${window.name}-${window.resetAt ?? "none"}`} className="quota-window-chip">
          {window.name}
          {typeof window.percentRemaining === "number" ? ` ${window.percentRemaining}%` : ""}
        </span>
      ))}
    </div>
  );
}
