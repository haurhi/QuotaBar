import type { ProviderDefinition } from "../shared/types";

interface ProviderIconProps {
  provider: ProviderDefinition;
}

const providerIconAssetById: Record<string, string> = {
  aliyun_coding_plan: "aliyunCodingPlan",
  tencent_cloud_coding_plan: "tencentCloudCodingPlan",
  volcengine_coding_plan: "volcengineCodingPlan",
  xfyun_coding_plan: "xfyunCodingPlan",
};

const providerIconAssetByName: Record<string, string> = {
  tencent: "tencentCloud",
};

function providerIconAsset(provider: ProviderDefinition) {
  return providerIconAssetById[provider.id] ?? providerIconAssetByName[provider.icon] ?? provider.icon;
}

export function ProviderIcon({ provider }: ProviderIconProps) {
  const asset = providerIconAsset(provider);

  return (
    <span className="provider-icon" data-provider={provider.id} aria-hidden="true">
      <img src={`/provider-icons/${asset}.png`} alt="" />
    </span>
  );
}
