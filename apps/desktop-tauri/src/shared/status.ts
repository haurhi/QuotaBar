import type { CredentialStatus, CredentialView, QuotaWindow } from "./types";

const attentionStatuses = new Set<CredentialStatus>([
  "failed",
  "expired",
  "usageLimitExceeded",
  "unsupported",
  "noSubscribedPlan",
]);

export function isAttentionStatus(status: CredentialStatus) {
  return attentionStatuses.has(status);
}

export function quotaWindowPercent(window: QuotaWindow) {
  return window.percentRemaining;
}

export function credentialPercentRemaining(credential: CredentialView) {
  const windowPercents = credential.quotaWindows
    .map(quotaWindowPercent)
    .filter((value): value is number => typeof value === "number");

  if (windowPercents.length > 0) {
    return Math.min(...windowPercents);
  }

  if (
    typeof credential.remaining === "number" &&
    typeof credential.limit === "number" &&
    credential.limit > 0
  ) {
    return (credential.remaining / credential.limit) * 100;
  }

  return undefined;
}

export function isLowCredential(credential: CredentialView) {
  const percent = credentialPercentRemaining(credential);
  return typeof percent === "number" && percent <= 20;
}

export function credentialNeedsAttention(credential: CredentialView) {
  if (!credential.active || credential.status === "disabled") {
    return false;
  }

  return isAttentionStatus(credential.status) || isLowCredential(credential);
}
