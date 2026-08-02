"use client";

import { useMemo, useState } from "react";
import type { ColumnDef } from "@tanstack/react-table";
import { PageHeader, StatusBadge } from "@/components/shared";
import { DataTable } from "@/components/tables/data-table";
import { Button } from "@/components/ui/button";
import { useStoreStore } from "@/stores/store-store";
import { useSubscriptionStore } from "@/stores/subscription-store";
import { useUserStore } from "@/stores/user-store";
import type { Store } from "@/types/store";

export default function StoresPage() {
  const stores = useStoreStore((s) => s.stores);
  const setStatus = useStoreStore((s) => s.setStatus);
  const deleteStore = useStoreStore((s) => s.deleteStore);
  const users = useUserStore((s) => s.users);
  const subscriptions = useSubscriptionStore((s) => s.subscriptions);
  const [statusFilter, setStatusFilter] = useState("all");

  const data = useMemo(
    () =>
      statusFilter === "all"
        ? stores
        : stores.filter((s) => s.status === statusFilter),
    [stores, statusFilter],
  );

  const columns = useMemo<ColumnDef<Store>[]>(
    () => [
      { accessorKey: "name", header: "Name" },
      {
        id: "owner",
        header: "Owner",
        cell: ({ row }) =>
          users.find((u) => u.id === row.original.ownerId)?.name ?? "—",
      },
      {
        accessorKey: "address",
        header: "Address",
        cell: ({ row }) => (
          <span>
            {row.original.address}, {row.original.city}
          </span>
        ),
      },
      { accessorKey: "category", header: "Category" },
      {
        id: "subscription",
        header: "Subscription",
        cell: ({ row }) => {
          const sub = subscriptions.find(
            (s) => s.id === row.original.subscriptionId,
          );
          return sub ? `${sub.plan} · ${sub.status}` : "None";
        },
      },
      {
        accessorKey: "status",
        header: "Status",
        cell: ({ row }) => <StatusBadge status={row.original.status} />,
      },
      {
        id: "actions",
        header: "Actions",
        cell: ({ row }) => {
          const s = row.original;
          return (
            <div className="flex flex-wrap gap-1">
              <Button size="sm" variant="outline" onClick={() => setStatus(s.id, "approved")}>
                Approve
              </Button>
              <Button size="sm" variant="secondary" onClick={() => setStatus(s.id, "rejected")}>
                Reject
              </Button>
              <Button
                size="sm"
                variant="outline"
                onClick={() =>
                  setStatus(s.id, s.status === "suspended" ? "active" : "suspended")
                }
              >
                {s.status === "suspended" ? "Activate" : "Suspend"}
              </Button>
              <Button
                size="sm"
                variant="destructive"
                onClick={() => {
                  if (confirm(`Delete ${s.name}?`)) deleteStore(s.id);
                }}
              >
                Delete
              </Button>
            </div>
          );
        },
      },
    ],
    [deleteStore, setStatus, subscriptions, users],
  );

  return (
    <div>
      <PageHeader
        title="Stores"
        description="Approve and moderate rental store businesses."
        actions={
          <select
            className="h-10 rounded-md border border-border bg-card px-3 text-sm"
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
          >
            <option value="all">All statuses</option>
            <option value="pending">Pending</option>
            <option value="active">Active</option>
            <option value="approved">Approved</option>
            <option value="suspended">Suspended</option>
            <option value="rejected">Rejected</option>
          </select>
        }
      />
      <DataTable
        columns={columns}
        data={data}
        searchPlaceholder="Search stores…"
        globalFilterFn={(row, q) =>
          [row.name, row.city, row.category, row.address]
            .join(" ")
            .toLowerCase()
            .includes(q)
        }
      />
    </div>
  );
}
