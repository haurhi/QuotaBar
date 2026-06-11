import type { ReactNode } from "react";

interface SidebarNavItemProps {
  icon: ReactNode;
  label: string;
  active?: boolean;
  onClick?: () => void;
}

export function SidebarNavItem({ icon, label, active = false, onClick }: SidebarNavItemProps) {
  return (
    <button className="sidebar-nav-item" data-active={active} onClick={onClick}>
      <span className="sidebar-nav-icon" aria-hidden="true">
        {icon}
      </span>
      <span>{label}</span>
    </button>
  );
}
