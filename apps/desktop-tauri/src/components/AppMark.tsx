interface AppMarkProps {
  className?: string;
  testId?: string;
}

export function AppMark({ className = "app-mark", testId }: AppMarkProps) {
  return (
    <span className={className} data-testid={testId} aria-hidden="true">
      <img src="/app-icon.png" alt="" />
    </span>
  );
}
