"use client";

import { useMemo, useState } from "react";
import type { ColumnDef } from "@tanstack/react-table";
import { PageHeader, StatusBadge } from "@/components/shared";
import { DataTable } from "@/components/tables/data-table";
import { Button } from "@/components/ui/button";
import { bookingStatusLabel, labelOf } from "@/lib/labels";
import { formatCurrency } from "@/lib/utils";
import { useBookingStore } from "@/stores/booking-store";
import { useDressStore } from "@/stores/dress-store";
import { useStoreStore } from "@/stores/store-store";
import { useUserStore } from "@/stores/user-store";
import type { Booking, BookingStatus } from "@/types/booking";

const STATUSES: BookingStatus[] = [
  "pending",
  "approved",
  "rejected",
  "completed",
  "cancelled",
  "returned",
];

export default function BookingsPage() {
  const bookings = useBookingStore((s) => s.bookings);
  const updateStatus = useBookingStore((s) => s.updateStatus);
  const users = useUserStore((s) => s.users);
  const dresses = useDressStore((s) => s.dresses);
  const stores = useStoreStore((s) => s.stores);
  const [statusFilter, setStatusFilter] = useState("all");

  const data = useMemo(
    () =>
      statusFilter === "all"
        ? bookings
        : bookings.filter((b) => b.status === statusFilter),
    [bookings, statusFilter],
  );

  const columns = useMemo<ColumnDef<Booking>[]>(
    () => [
      {
        accessorKey: "id",
        header: "رقم الحجز",
        cell: ({ row }) => <span dir="ltr">{row.original.id}</span>,
      },
      {
        id: "customer",
        header: "الزبون",
        cell: ({ row }) =>
          users.find((u) => u.id === row.original.customerId)?.name ?? "—",
      },
      {
        id: "dress",
        header: "الفستان",
        cell: ({ row }) =>
          dresses.find((d) => d.id === row.original.dressId)?.name ?? "—",
      },
      {
        id: "store",
        header: "المحل",
        cell: ({ row }) =>
          stores.find((s) => s.id === row.original.storeId)?.name ?? "مؤجّر",
      },
      {
        id: "dates",
        header: "التواريخ",
        cell: ({ row }) => (
          <span dir="ltr">
            {row.original.startDate} → {row.original.endDate}
          </span>
        ),
      },
      {
        accessorKey: "price",
        header: "المبلغ",
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
        cell: ({ row }) => (
          <div className="flex flex-wrap gap-1">
            <select
              className="h-8 rounded-md border border-border bg-card px-2 text-xs"
              value={row.original.status}
              onChange={(e) =>
                updateStatus(row.original.id, e.target.value as BookingStatus)
              }
            >
              {STATUSES.map((s) => (
                <option key={s} value={s}>
                  {labelOf(bookingStatusLabel, s)}
                </option>
              ))}
            </select>
            <Button
              size="sm"
              variant="destructive"
              onClick={() => updateStatus(row.original.id, "cancelled")}
            >
              إلغاء
            </Button>
          </div>
        ),
      },
    ],
    [dresses, stores, updateStatus, users],
  );

  return (
    <div>
      <PageHeader
        title="الحجوزات"
        description="إدارة طلبات الإيجار بين الزبائن والمؤجّرين والمحلات."
        actions={
          <select
            className="h-10 rounded-md border border-border bg-card px-3 text-sm"
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
          >
            <option value="all">كل الحالات</option>
            {STATUSES.map((s) => (
              <option key={s} value={s}>
                {labelOf(bookingStatusLabel, s)}
              </option>
            ))}
          </select>
        }
      />
      <DataTable
        columns={columns}
        data={data}
        searchPlaceholder="ابحث في الحجوزات…"
        globalFilterFn={(row, q) =>
          [row.id, row.status, row.customerId, row.dressId]
            .join(" ")
            .toLowerCase()
            .includes(q)
        }
      />
    </div>
  );
}
