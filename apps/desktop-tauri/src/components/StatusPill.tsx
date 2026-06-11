interface StatusPillProps {
  tone: "healthy" | "attention";
  label: string;
}

export function StatusPill({ tone, label }: StatusPillProps) {
  return (
    <span className="status-pill" data-tone={tone}>
      <span className="status-dot" aria-hidden="true" />
      {label}
    </span>
  );
}
