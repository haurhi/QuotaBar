import { ProviderCategorySection } from "../quota/ProviderCategorySection";
import { useLocale } from "../i18n";
import { mockCredentials, providerRegistry } from "../shared/mockData";
import { buildProviderStats } from "../shared/selectors";
import type { CredentialView, ProviderCategory, ProviderDefinition } from "../shared/types";

const categoryOrder: ProviderCategory[] = ["AI Search", "LLM"];

interface QuotaMonitoringPageProps {
  providers?: ProviderDefinition[];
  credentials?: CredentialView[];
  onRefreshProvider?: (providerId: string) => void | Promise<void>;
  onStartWebAuthorization?: (providerId: string, targetCredentialId?: string) => void | Promise<void>;
}

export function QuotaMonitoringPage({
  providers = providerRegistry,
  credentials = mockCredentials,
  onRefreshProvider,
  onStartWebAuthorization,
}: QuotaMonitoringPageProps) {
  const locale = useLocale();
  const stats = buildProviderStats(providers, credentials, locale);

  return (
    <div className="quota-page">
      {categoryOrder.map((category) => {
        const categoryStats = stats.filter((stat) => stat.provider.category === category);
        if (categoryStats.length === 0) {
          return null;
        }

        return (
          <ProviderCategorySection
            key={category}
            category={category}
            stats={categoryStats}
            onRefreshProvider={onRefreshProvider}
            onStartWebAuthorization={onStartWebAuthorization}
          />
        );
      })}
    </div>
  );
}
