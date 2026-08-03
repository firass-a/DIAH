"use client";

import Image from "next/image";
import { useMemo, useState } from "react";
import type { ColumnDef } from "@tanstack/react-table";
import { PageHeader, StatusBadge } from "@/components/shared";
import { DataTable } from "@/components/tables/data-table";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { dressCategoryLabel, labelOf } from "@/lib/labels";
import { formatCurrency } from "@/lib/utils";
import { useDressStore } from "@/stores/dress-store";
import { useStoreStore } from "@/stores/store-store";
import { useUserStore } from "@/stores/user-store";
import type { Dress } from "@/types/dress";

export default function DressesPage() {
  const dresses = useDressStore((s) => s.dresses);
  const approveDress = useDressStore((s) => s.approveDress);
  const rejectDress = useDressStore((s) => s.rejectDress);
  const hideDress = useDressStore((s) => s.hideDress);
  const deleteDress = useDressStore((s) => s.deleteDress);
  const users = useUserStore((s) => s.users);
  const stores = useStoreStore((s) => s.stores);
  const [statusFilter, setStatusFilter] = useState("all");
  const [selected, setSelected] = useState<Dress | null>(null);

  const data = useMemo(
    () =>
      statusFilter === "all"
        ? dresses
        : dresses.filter((d) => d.status === statusFilter),
    [dresses, statusFilter],
  );

  const columns = useMemo<ColumnDef<Dress>[]>(
    () => [
      {
        id: "image",
        header: "الصورة",
        cell: ({ row }) => (
          <Image
            src={row.original.images[0] ?? ""}
            alt={row.original.name}
            width={48}
            height={56}
            className="h-14 w-12 rounded-md object-cover"
            unoptimized
          />
        ),
      },
      { accessorKey: "name", header: "الاسم" },
      {
        id: "owner",
        header: "المالك",
        cell: ({ row }) =>
          users.find((u) => u.id === row.original.ownerId)?.name ?? "—",
      },
      {
        id: "store",
        header: "المحل",
        cell: ({ row }) =>
          stores.find((s) => s.id === row.original.storeId)?.name ?? "شخصي",
      },
      {
        accessorKey: "category",
        header: "الفئة",
        cell: ({ row }) =>
          labelOf(dressCategoryLabel, row.original.category),
      },
      {
        accessorKey: "price",
        header: "السعر",
        cell: ({ row }) => (
          <span dir="ltr">{formatCurrency(row.original.price)}</span>
        ),
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
          const d = row.original;
          return (
            <div className="flex flex-wrap gap-1">
              <Button size="sm" variant="outline" onClick={() => setSelected(d)}>
                عرض
              </Button>
              <Button size="sm" variant="outline" onClick={() => approveDress(d.id)}>
                قبول
              </Button>
              <Button size="sm" variant="secondary" onClick={() => rejectDress(d.id)}>
                رفض
              </Button>
              <Button size="sm" variant="outline" onClick={() => hideDress(d.id)}>
                إخفاء
              </Button>
              <Button
                size="sm"
                variant="destructive"
                onClick={() => {
                  if (confirm(`حذف ${d.name}؟`)) deleteDress(d.id);
                }}
              >
                حذف
              </Button>
            </div>
          );
        },
      },
    ],
    [approveDress, deleteDress, hideDress, rejectDress, stores, users],
  );

  return (
    <div>
      <PageHeader
        title="الفساتين"
        description="مراجعة قوائم الفساتين الشخصية وتلك التابعة للمحلات."
        actions={
          <select
            className="h-10 rounded-md border border-border bg-card px-3 text-sm"
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
          >
            <option value="all">الكل</option>
            <option value="pending">قيد المراجعة</option>
            <option value="available">متاح</option>
            <option value="rejected">مرفوض</option>
            <option value="hidden">مخفي</option>
          </select>
        }
      />
      <DataTable
        columns={columns}
        data={data}
        searchPlaceholder="ابحث عن فستان…"
        globalFilterFn={(row, q) =>
          [row.name, row.category, row.color, row.status]
            .join(" ")
            .toLowerCase()
            .includes(q)
        }
      />

      <Dialog open={!!selected} onOpenChange={() => setSelected(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{selected?.name}</DialogTitle>
          </DialogHeader>
          {selected ? (
            <div className="space-y-3">
              <Image
                src={selected.images[0]}
                alt={selected.name}
                width={480}
                height={280}
                className="h-56 w-full rounded-lg object-cover"
                unoptimized
              />
              <p className="text-sm text-muted-foreground">{selected.description}</p>
              <div className="grid grid-cols-2 gap-2 text-sm">
                <p>الفئة: {labelOf(dressCategoryLabel, selected.category)}</p>
                <p>اللون: {selected.color}</p>
                <p>المقاس: {selected.size}</p>
                <p>
                  السعر: <span dir="ltr">{formatCurrency(selected.price)}</span>
                </p>
                <p>
                  التأمين:{" "}
                  <span dir="ltr">{formatCurrency(selected.deposit)}</span>
                </p>
                <p>
                  مرات الإيجار: <span dir="ltr">{selected.rentalCount}</span>
                </p>
              </div>
            </div>
          ) : null}
        </DialogContent>
      </Dialog>
    </div>
  );
}
