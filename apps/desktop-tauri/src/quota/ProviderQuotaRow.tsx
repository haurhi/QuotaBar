import { ExternalLink, RefreshCw, RotateCcw } from "lucide-react";
import { ProviderIcon } from "../components/ProviderIcon";
import { StatusPill } from "../components/StatusPill";
import { translate } from "../i18n";
import type { ProviderStats } from "../shared/types";
import { CredentialDetailTable } from "./CredentialDetailTable";

interface ProviderQuotaRowProps {
  stat: ProviderStats;
  expanded: boolean;
  onToggle: () => void;
  onRefreshProvider?: (providerId: string) => void | Promise<void>;
  onStartWebAuthorization?: (providerId: string, targetCredentialId?: string) => void | Promise<void>;
}

export function ProviderQuotaRow({
  stat,
  expanded,
  onToggle,
  onRefreshProvider,
  onStartWebAuthorization,
}: ProviderQuotaRowProps) {
  const tone = stat.needsAttention ? "attention" : "healthy";
  const authorizationCredentials = stat.credentials.filter(
    (credential) => credential.kind === "dashboardCookie",
  );
  const reauthorizationTarget =
    authorizationCredentials.length === 1 ? authorizationCredentials[0] : undefined;
  const reauthorizationLabel = reauthorizationTarget?.name ?? (
    authorizationCredentials.length > 1 ? "choose account" : undefined
  );
  const subtitle = [
    stat.provider.familyName !== stat.provider.displayName ? stat.provider.familyName : undefined,
    stat.provider.planType,
  ]
    .filter(Boolean)
    .join(" · ");

  return (
    <>
      <tr className="provider-row" data-expanded={expanded} onClick={onToggle}>
        <td>
          <div className="provider-cell">
            <ProviderIcon provider={stat.provider} />
            <div>
              <div className="provider-name">{stat.provider.displayName}</div>
              {subtitle ? <div className="provider-subtitle">{subtitle}</div> : null}
              {stat.provider.quotaCheckConsumesSearchQuota ? (
                <div className="provider-warning">Refresh uses one search request</div>
              ) : null}
            </div>
          </div>
        </td>
        <td className="numeric-cell">{stat.keyQuotaText}</td>
        <td className="numeric-cell">{stat.credentialPoolText}</td>
        <td className="numeric-cell">{stat.criticalTimeText}</td>
        <td>
          <StatusPill tone={tone} label={stat.statusText} />
        </td>
        <td>
          <div className="quota-actions" onClick={(event) => event.stopPropagation()}>
            {stat.provider.dashboardUrl ? (
              <button aria-label={`${stat.provider.displayName} ${translate("action.openDashboard")}`}>
                <ExternalLink size={14} />
              </button>
            ) : null}
            {stat.provider.supportsReauth ? (
              <button
                aria-label={[
                  stat.provider.displayName,
                  translate("action.reauthorize"),
                  reauthorizationLabel,
                ].filter(Boolean).join(" ")}
                onClick={() => {
                  void onStartWebAuthorization?.(stat.provider.id, reauthorizationTarget?.id);
                }}
              >
                <RotateCcw size={14} />
              </button>
            ) : null}
            {stat.provider.supportsRefresh ? (
              <button
                aria-label={`${stat.provider.displayName} ${translate("action.refresh")}`}
                onClick={() => {
                  void onRefreshProvider?.(stat.provider.id);
                }}
              >
                <RefreshCw size={14} />
              </button>
            ) : null}
          </div>
        </td>
      </tr>
      {expanded ? (
        <tr className="provider-detail-row">
          <td colSpan={6}>
            <CredentialDetailTable credentials={stat.credentials} />
          </td>
        </tr>
      ) : null}
    </>
  );
}
