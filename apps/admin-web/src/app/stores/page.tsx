"use client";

import { useMemo, useState } from "react";
import type { ColumnDef } from "@tanstack/react-table";
import { PageHeader, StatusBadge } from "@/components/shared";
import { DataTable } from "@/components/tables/data-table";
import { Button } from "@/components/ui/button";
import { labelOf, planLabel, statusLabel, storeCategoryLabel } from "@/lib/labels";
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
      { accessorKey: "name", header: "الاسم" },
      {
        id: "owner",
        header: "المالك",
        cell: ({ row }) =>
          users.find((u) => u.id === row.original.ownerId)?.name ?? "—",
      },
      {
        accessorKey: "address",
        header: "العنوان",
        cell: ({ row }) => (
          <span>
            {row.original.address}، {row.original.city}
          </span>
        ),
      },
      {
        accessorKey: "category",
        header: "الفئة",
        cell: ({ row }) =>
          labelOf(storeCategoryLabel, row.original.category),
      },
      {
        id: "subscription",
        header: "الاشتراك",
        cell: ({ row }) => {
          const sub = subscriptions.find(
            (s) => s.id === row.original.subscriptionId,
          );
          return sub
            ? `${labelOf(planLabel, sub.plan)} · ${labelOf(statusLabel, sub.status)}`
            : "لا يوجد";
        },
      },
      {
        accessorKey: "status",
        header: "الحالة",
        cell: ({ row }) => <StatusBadge status={row.original.status} />,
      },
      {
        id: "actions",
        header: "إجراءات",
        cell: ({ row }) => {
          const s = row.original;
          return (
            <div className="flex flex-wrap gap-1">
              <Button size="sm" variant="outline" onClick={() => setStatus(s.id, "approved")}>
                قبول
              </Button>
              <Button size="sm" variant="secondary" onClick={() => setStatus(s.id, "rejected")}>
                رفض
              </Button>
              <Button
                size="sm"
                variant="outline"
                onClick={() =>
                  setStatus(s.id, s.status === "suspended" ? "active" : "suspended")
                }
              >
                {s.status === "suspended" ? "تفعيل" : "إيقاف"}
              </Button>
              <Button
                size="sm"
                variant="destructive"
                onClick={() => {
                  if (confirm(`حذف ${s.name}؟`)) deleteStore(s.id);
                }}
              >
                حذف
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
        title="المحلات"
        description="الموافقة على محلات التأجير وإدارتها."
        actions={
          <select
            className="h-10 rounded-md border border-border bg-card px-3 text-sm"
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
          >
            <option value="all">كل الحالات</option>
            <option value="pending">قيد المراجعة</option>
            <option value="active">نشط</option>
            <option value="approved">مقبول</option>
            <option value="suspended">موقوف</option>
            <option value="rejected">مرفوض</option>
          </select>
        }
      />
      <DataTable
        columns={columns}
        data={data}
        searchPlaceholder="ابحث عن محل…"
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
