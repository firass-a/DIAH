"use client";

import { useMemo } from "react";
import type { ColumnDef } from "@tanstack/react-table";
import { PageHeader, StatusBadge } from "@/components/shared";
import { DataTable } from "@/components/tables/data-table";
import { Button } from "@/components/ui/button";
import { SUBSCRIPTION_PLANS } from "@/lib/constants";
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
        header: "Store",
        cell: ({ row }) =>
          stores.find((s) => s.id === row.original.storeId)?.name ?? "—",
      },
      { accessorKey: "plan", header: "Plan" },
      {
        accessorKey: "price",
        header: "Price",
        cell: ({ row }) => formatCurrency(row.original.price),
      },
      { accessorKey: "startDate", header: "Start" },
      { accessorKey: "endDate", header: "End" },
      {
        accessorKey: "status",
        header: "Status",
        cell: ({ row }) => <StatusBadge status={row.original.status} />,
      },
      {
        id: "actions",
        header: "Actions",
        cell: ({ row }) => (
          <div className="flex flex-wrap gap-1">
            <Button
              size="sm"
              variant="outline"
              onClick={() => setStatus(row.original.id, "active")}
            >
              Activate
            </Button>
            <Button
              size="sm"
              variant="secondary"
              onClick={() => setStatus(row.original.id, "cancelled")}
            >
              Disable
            </Button>
            <Button size="sm" onClick={() => renew(row.original.id)}>
              Renew
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
        title="Subscriptions"
        description="Store plans, renewals, and billing status."
      />
      <div className="mb-6 grid gap-3 sm:grid-cols-3">
        {SUBSCRIPTION_PLANS.map((p) => (
          <div
            key={p.id}
            className="rounded-xl border border-border bg-card p-4"
          >
            <p className="font-display text-xl font-semibold">{p.name}</p>
            <p className="text-sm text-muted-foreground">
              {formatCurrency(p.price)}
              {p.id === "monthly"
                ? " / month"
                : p.id === "yearly"
                  ? " / year"
                  : " trial"}
            </p>
          </div>
        ))}
      </div>
      <DataTable
        columns={columns}
        data={subscriptions}
        searchPlaceholder="Search subscriptions…"
        globalFilterFn={(row, q) =>
          [row.plan, row.status, row.storeId].join(" ").toLowerCase().includes(q)
        }
      />
    </div>
  );
}
