"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  BarChart3,
  Bell,
  CalendarDays,
  CreditCard,
  LayoutDashboard,
  Settings,
  Shirt,
  Store,
  Users,
  Wallet,
} from "lucide-react";
import { NAV_ITEMS } from "@/lib/constants";
import { cn } from "@/lib/utils";

const icons = {
  LayoutDashboard,
  Users,
  Store,
  Shirt,
  CalendarDays,
  Wallet,
  CreditCard,
  BarChart3,
  Bell,
  Settings,
} as const;

export function Sidebar({ mobile = false }: { mobile?: boolean }) {
  const pathname = usePathname();

  return (
    <aside
      className={
        mobile
          ? "flex h-full w-64 flex-col border-r border-border bg-card"
          : "hidden w-64 shrink-0 border-r border-border bg-card lg:flex lg:flex-col"
      }
    >
      <div className="flex h-16 items-center gap-3 border-b border-border px-6">
        <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary text-sm font-bold text-white">
          D
        </div>
        <div>
          <p className="font-display text-xl font-semibold leading-none">Diah</p>
          <p className="text-[11px] text-muted-foreground">Admin Console</p>
        </div>
      </div>
      <nav className="flex-1 space-y-1 p-3">
        {NAV_ITEMS.map((item) => {
          const Icon = icons[item.icon];
          const active =
            pathname === item.href || pathname.startsWith(`${item.href}/`);
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors",
                active
                  ? "bg-primary/12 text-primary"
                  : "text-muted-foreground hover:bg-muted hover:text-foreground",
              )}
            >
              <Icon className="h-4 w-4" />
              {item.label}
            </Link>
          );
        })}
      </nav>
      <div className="border-t border-border p-4 text-xs text-muted-foreground">
        Prototype · local state only
      </div>
    </aside>
  );
}
