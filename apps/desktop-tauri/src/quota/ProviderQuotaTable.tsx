import { useState } from "react";
import { useTranslate } from "../i18n";
import type { ProviderStats } from "../shared/types";
import { ProviderQuotaRow } from "./ProviderQuotaRow";

interface ProviderQuotaTableProps {
  stats: ProviderStats[];
  onRefreshProvider?: (providerId: string) => void | Promise<void>;
  onStartWebAuthorization?: (providerId: string, targetCredentialId?: string) => void | Promise<void>;
}

export function ProviderQuotaTable({
  stats,
  onRefreshProvider,
  onStartWebAuthorization,
}: ProviderQuotaTableProps) {
  const t = useTranslate();
  const [expandedProviderId, setExpandedProviderId] = useState<string | null>(null);

  return (
    <table className="provider-table">
      <thead>
        <tr>
          <th>{t("quota.provider")}</th>
          <th>{t("quota.keyQuota")}</th>
          <th>{t("quota.credentialPool")}</th>
          <th>{t("quota.criticalTime")}</th>
          <th>{t("quota.status")}</th>
          <th>{t("quota.actions")}</th>
        </tr>
      </thead>
      <tbody>
        {stats.map((stat) => (
          <ProviderQuotaRow
            key={stat.provider.id}
            stat={stat}
            expanded={expandedProviderId === stat.provider.id}
            onToggle={() =>
              setExpandedProviderId((current) => (current === stat.provider.id ? null : stat.provider.id))
            }
            onRefreshProvider={onRefreshProvider}
            onStartWebAuthorization={onStartWebAuthorization}
          />
        ))}
      </tbody>
    </table>
  );
}
