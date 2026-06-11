import { translate } from "../i18n";
import { credentialNeedsAttention } from "../shared/status";
import type { CredentialView } from "../shared/types";
import { QuotaWindowDetails } from "../components/QuotaWindowDetails";
import { StatusPill } from "../components/StatusPill";

interface CredentialDetailTableProps {
  credentials: CredentialView[];
}

export function CredentialDetailTable({ credentials }: CredentialDetailTableProps) {
  return (
    <div className="credential-detail">
      <table className="credential-table">
        <thead>
          <tr>
            <th>{translate("quota.credential")}</th>
            <th>{translate("quota.remaining")}</th>
            <th>{translate("quota.status")}</th>
            <th>{translate("quota.lastUpdated")}</th>
          </tr>
        </thead>
        <tbody>
          {credentials.map((credential) => (
            <tr key={credential.id}>
              <td>
                <div className="credential-name">{credential.name}</div>
                <div className="credential-subtitle">
                  {credential.maskedValue} · {credential.kind}
                </div>
                <QuotaWindowDetails windows={credential.quotaWindows} />
              </td>
              <td className="numeric-cell">{credential.remainingBadgeText}</td>
              <td>
                <StatusPill
                  tone={credentialNeedsAttention(credential) ? "attention" : "healthy"}
                  label={credential.status}
                />
              </td>
              <td className="timing-cell">
                <div>{credential.lastUpdated ?? "N/A"}</div>
                {credential.resetAt ? <small>Reset {credential.resetAt}</small> : null}
                {credential.planEndsAt ? <small>Plan ends {credential.planEndsAt}</small> : null}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
