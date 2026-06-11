import { useState } from "react";
import { translate } from "../i18n";
import type { ProviderStats } from "../shared/types";
import { ProviderQuotaRow } from "./ProviderQuotaRow";

interface ProviderQuotaTableProps {
  stats: ProviderStats[];
}

export function ProviderQuotaTable({ stats }: ProviderQuotaTableProps) {
  const [expandedProviderId, setExpandedProviderId] = useState<string | null>(null);

  return (
    <table className="provider-table">
      <thead>
        <tr>
          <th>{translate("quota.provider")}</th>
          <th>{translate("quota.keyQuota")}</th>
          <th>{translate("quota.credentialPool")}</th>
          <th>{translate("quota.criticalTime")}</th>
          <th>{translate("quota.status")}</th>
          <th>{translate("quota.actions")}</th>
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
          />
        ))}
      </tbody>
    </table>
  );
}
