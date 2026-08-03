"use client";

import { useMemo } from "react";
import type { ColumnDef } from "@tanstack/react-table";
import { PageHeader, StatusBadge } from "@/components/shared";
import { DataTable } from "@/components/tables/data-table";
import { Button } from "@/components/ui/button";
import { SUBSCRIPTION_PLANS } from "@/lib/constants";
import { labelOf, planLabel } from "@/lib/labels";
import { formatCurrency } from "@/lib/utils";
import { useStoreStore } from "@/stores/store-store";
import { useSubscriptionStore } from "@/stores/subscription-store";
import type { Subscription } from "@/types/subscription";

export default function SubscriptionsPage() {
  const subscriptions = useSubscriptionStore((s) => s.subscriptions);
  const setStatus = useSubscriptionStore((s) => s.setStatus);
  const renew = useSubscriptionStore((s) => s.renew);
  const stores = useStoreStore((s) => s.stores);

  const columns = useMemo<ColumnDef<Subscription>[]>(
    () => [
      {
        id: "store",
        header: "المحل",
        cell: ({ row }) =>
          stores.find((s) => s.id === row.original.storeId)?.name ?? "—",
      },
      {
        accessorKey: "plan",
        header: "الخطة",
        cell: ({ row }) => labelOf(planLabel, row.original.plan),
      },
      {
        accessorKey: "price",
        header: "السعر",
        cell: ({ row }) => (
          <span dir="ltr">{formatCurrency(row.original.price)}</span>
        ),
      },
      {
        accessorKey: "startDate",
        header: "البداية",
        cell: ({ row }) => <span dir="ltr">{row.original.startDate}</span>,
      },
      {
        accessorKey: "endDate",
        header: "النهاية",
        cell: ({ row }) => <span dir="ltr">{row.original.endDate}</span>,
      },
      {
        accessorKey: "status",
        header: "الحالة",
        cell: ({ row }) => <StatusBadge status={row.original.status} />,
      },
      {
        id: "actions",
        header: "إجراءات",
        cell: ({ row }) => (
          <div className="flex flex-wrap gap-1">
            <Button
              size="sm"
              variant="outline"
              onClick={() => setStatus(row.original.id, "active")}
            >
              تفعيل
            </Button>
            <Button
              size="sm"
              variant="secondary"
              onClick={() => setStatus(row.original.id, "cancelled")}
            >
              تعطيل
            </Button>
            <Button size="sm" onClick={() => renew(row.original.id)}>
              تجديد
            </Button>
          </div>
        ),
      },
    ],
    [renew, setStatus, stores],
  );

  return (
    <div>
      <PageHeader
        title="الاشتراكات"
        description="خطط المحلات والتجديدات وحالة الفوترة."
      />
      <div className="mb-6 grid gap-3 sm:grid-cols-3">
        {SUBSCRIPTION_PLANS.map((p) => (
          <div
            key={p.id}
            className="rounded-xl border border-border bg-card p-4"
          >
            <p className="font-display text-xl font-semibold">{p.name}</p>
            <p className="text-sm text-muted-foreground">
              <span dir="ltr">{formatCurrency(p.price)}</span>
              {p.id === "monthly"
                ? " / شهر"
                : p.id === "yearly"
                  ? " / سنة"
                  : " تجريبي"}
            </p>
          </div>
        ))}
      </div>
      <DataTable
        columns={columns}
        data={subscriptions}
        searchPlaceholder="ابحث في الاشتراكات…"
        globalFilterFn={(row, q) =>
          [row.plan, row.status, row.storeId].join(" ").toLowerCase().includes(q)
        }
      />
    </div>
  );
}
