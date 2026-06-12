import { useState } from "react";
import { useTranslate } from "../i18n";
import type { ProviderCategory, ProviderStats } from "../shared/types";
import { ProviderQuotaTable } from "./ProviderQuotaTable";

interface ProviderCategorySectionProps {
  category: ProviderCategory;
  stats: ProviderStats[];
  onRefreshProvider?: (providerId: string) => void | Promise<void>;
  onStartWebAuthorization?: (providerId: string, targetCredentialId?: string) => void | Promise<void>;
}

export function ProviderCategorySection({
  category,
  stats,
  onRefreshProvider,
  onStartWebAuthorization,
}: ProviderCategorySectionProps) {
  const t = useTranslate();
  const [expanded, setExpanded] = useState(true);
  const credentialCount = stats.reduce((total, stat) => total + stat.credentials.length, 0);
  const categoryTitle = category === "AI Search" ? t("category.aiSearch") : t("category.llm");
  const summary = t("quota.categorySummary")
    .replace("{providers}", String(stats.length))
    .replace("{credentials}", String(credentialCount));

  return (
    <section className="quota-category" data-expanded={expanded}>
      <button className="quota-category-banner" onClick={() => setExpanded((value) => !value)}>
        <div>
          <h2>{categoryTitle}</h2>
          <p>{summary}</p>
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
