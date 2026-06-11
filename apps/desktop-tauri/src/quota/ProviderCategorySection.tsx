import { useState } from "react";
import { translate } from "../i18n";
import type { ProviderCategory, ProviderStats } from "../shared/types";
import { ProviderQuotaTable } from "./ProviderQuotaTable";

interface ProviderCategorySectionProps {
  category: ProviderCategory;
  stats: ProviderStats[];
  onRefreshProvider?: (providerId: string) => void | Promise<void>;
  onStartWebAuthorization?: (providerId: string, targetCredentialId?: string) => void | Promise<void>;
}

function categoryTitle(category: ProviderCategory) {
  return category === "AI Search" ? translate("category.aiSearch") : translate("category.llm");
}

export function ProviderCategorySection({
  category,
  stats,
  onRefreshProvider,
  onStartWebAuthorization,
}: ProviderCategorySectionProps) {
  const [expanded, setExpanded] = useState(true);
  const credentialCount = stats.reduce((total, stat) => total + stat.credentials.length, 0);

  return (
    <section className="quota-category" data-expanded={expanded}>
      <button className="quota-category-banner" onClick={() => setExpanded((value) => !value)}>
        <div>
          <h2>{categoryTitle(category)}</h2>
          <p>
            {stats.length} providers · {credentialCount} credentials
          </p>
        </div>
      </button>
      {expanded ? (
        <ProviderQuotaTable
          stats={stats}
          onRefreshProvider={onRefreshProvider}
          onStartWebAuthorization={onStartWebAuthorization}
        />
      ) : null}
    </section>
  );
}
