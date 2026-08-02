"use client";

import { useMemo, useState } from "react";
import type { ColumnDef } from "@tanstack/react-table";
import { PageHeader, StatusBadge } from "@/components/shared";
import { DataTable } from "@/components/tables/data-table";
import { Button } from "@/components/ui/button";
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
      { accessorKey: "id", header: "Booking ID" },
      {
        id: "customer",
        header: "Customer",
        cell: ({ row }) =>
          users.find((u) => u.id === row.original.customerId)?.name ?? "—",
      },
      {
        id: "dress",
        header: "Dress",
        cell: ({ row }) =>
          dresses.find((d) => d.id === row.original.dressId)?.name ?? "—",
      },
      {
        id: "store",
        header: "Store",
        cell: ({ row }) =>
          stores.find((s) => s.id === row.original.storeId)?.name ?? "Owner",
      },
      {
        id: "dates",
        header: "Dates",
        cell: ({ row }) =>
          `${row.original.startDate} → ${row.original.endDate}`,
      },
      {
        accessorKey: "price",
        header: "Amount",
        cell: ({ row }) => formatCurrency(row.original.price),
      },
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
            <select
              className="h-8 rounded-md border border-border bg-card px-2 text-xs"
              value={row.original.status}
              onChange={(e) =>
                updateStatus(row.original.id, e.target.value as BookingStatus)
              }
            >
              {STATUSES.map((s) => (
                <option key={s} value={s}>
                  {s}
                </option>
              ))}
            </select>
            <Button
              size="sm"
              variant="destructive"
              onClick={() => updateStatus(row.original.id, "cancelled")}
            >
              Cancel
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
        title="Bookings"
        description="Control rental requests across customers, owners, and stores."
        actions={
          <select
            className="h-10 rounded-md border border-border bg-card px-3 text-sm"
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
          >
            <option value="all">All statuses</option>
            {STATUSES.map((s) => (
              <option key={s} value={s}>
                {s}
              </option>
            ))}
          </select>
        }
      />
      <DataTable
        columns={columns}
        data={data}
        searchPlaceholder="Search bookings…"
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
