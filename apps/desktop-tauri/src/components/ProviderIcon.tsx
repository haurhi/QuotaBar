import type { ProviderDefinition } from "../shared/types";

interface ProviderIconProps {
  provider: ProviderDefinition;
}

export function ProviderIcon({ provider }: ProviderIconProps) {
  return (
    <span className="provider-icon" data-provider={provider.id} aria-hidden="true">
      {provider.displayName.slice(0, 1)}
    </span>
  );
}
