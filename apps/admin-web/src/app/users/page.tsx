"use client";

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
import { formatDate } from "@/lib/utils";
import { useBookingStore } from "@/stores/booking-store";
import { useDressStore } from "@/stores/dress-store";
import { useTransactionStore } from "@/stores/transaction-store";
import { useUserStore } from "@/stores/user-store";
import type { User } from "@/types/user";

export default function UsersPage() {
  const users = useUserStore((s) => s.users);
  const setStatus = useUserStore((s) => s.setStatus);
  const deleteUser = useUserStore((s) => s.deleteUser);
  const updateUser = useUserStore((s) => s.updateUser);
  const bookings = useBookingStore((s) => s.bookings);
  const dresses = useDressStore((s) => s.dresses);
  const transactions = useTransactionStore((s) => s.transactions);
  const [selected, setSelected] = useState<User | null>(null);
  const [roleFilter, setRoleFilter] = useState("all");

  const data = useMemo(
    () =>
      roleFilter === "all"
        ? users
        : users.filter((u) => u.role === roleFilter),
    [users, roleFilter],
  );

  const columns = useMemo<ColumnDef<User>[]>(
    () => [
      {
        accessorKey: "name",
        header: "Name",
        cell: ({ row }) => (
          <div>
            <p className="font-medium">{row.original.name}</p>
            <p className="text-xs text-muted-foreground">{row.original.email}</p>
          </div>
        ),
      },
      { accessorKey: "phone", header: "Phone" },
      {
        accessorKey: "role",
        header: "Role",
        cell: ({ row }) => <StatusBadge status={row.original.role} />,
      },
      {
        accessorKey: "createdAt",
        header: "Registered",
        cell: ({ row }) => formatDate(row.original.createdAt),
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
          const u = row.original;
          return (
            <div className="flex flex-wrap gap-1">
              <Button size="sm" variant="outline" onClick={() => setSelected(u)}>
                View
              </Button>
              <Button
                size="sm"
                variant="outline"
                onClick={() =>
                  updateUser(u.id, {
                    city: u.city === "Algiers" ? "Oran" : "Algiers",
                  })
                }
              >
                Edit
              </Button>
              <Button
                size="sm"
                variant="secondary"
                onClick={() =>
                  setStatus(
                    u.id,
                    u.status === "suspended" ? "active" : "suspended",
                  )
                }
              >
                {u.status === "suspended" ? "Activate" : "Suspend"}
              </Button>
              <Button
                size="sm"
                variant="destructive"
                onClick={() => {
                  if (confirm(`Delete ${u.name}?`)) deleteUser(u.id);
                }}
              >
                Delete
              </Button>
            </div>
          );
        },
      },
    ],
    [deleteUser, setStatus, updateUser],
  );

  const userBookings = selected
    ? bookings.filter((b) => b.customerId === selected.id)
    : [];
  const userDresses = selected
    ? dresses.filter((d) => d.ownerId === selected.id)
    : [];
  const userTx = selected
    ? transactions.filter((t) => t.customerId === selected.id)
    : [];

  return (
    <div>
      <PageHeader
        title="Users"
        description="Manage customers, individual owners, and store owners."
        actions={
          <select
            className="h-10 rounded-md border border-border bg-card px-3 text-sm"
            value={roleFilter}
            onChange={(e) => setRoleFilter(e.target.value)}
          >
            <option value="all">All roles</option>
            <option value="customer">Customers</option>
            <option value="individualOwner">Individual owners</option>
            <option value="storeOwner">Store owners</option>
          </select>
        }
      />
      <DataTable
        columns={columns}
        data={data}
        searchPlaceholder="Search name, phone, email…"
        globalFilterFn={(row, q) =>
          [row.name, row.phone, row.email, row.role, row.city]
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
            <div className="space-y-3 text-sm">
              <p>
                <span className="text-muted-foreground">Phone:</span>{" "}
                {selected.phone}
              </p>
              <p>
                <span className="text-muted-foreground">Email:</span>{" "}
                {selected.email}
              </p>
              <p>
                <span className="text-muted-foreground">City:</span>{" "}
                {selected.city}
              </p>
              <p>
                <span className="text-muted-foreground">Role:</span>{" "}
                {selected.role}
              </p>
              <div className="rounded-lg bg-muted p-3">
                <p className="font-medium">Bookings: {userBookings.length}</p>
                <p className="font-medium">Owned dresses: {userDresses.length}</p>
                <p className="font-medium">Transactions: {userTx.length}</p>
              </div>
            </div>
          ) : null}
        </DialogContent>
      </Dialog>
    </div>
  );
}
