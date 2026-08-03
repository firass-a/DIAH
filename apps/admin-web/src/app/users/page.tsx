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
import { labelOf, roleLabel } from "@/lib/labels";
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
        header: "الاسم",
        cell: ({ row }) => (
          <div>
            <p className="font-medium">{row.original.name}</p>
            <p className="text-xs text-muted-foreground" dir="ltr">
              {row.original.email}
            </p>
          </div>
        ),
      },
      {
        accessorKey: "phone",
        header: "الهاتف",
        cell: ({ row }) => <span dir="ltr">{row.original.phone}</span>,
      },
      {
        accessorKey: "role",
        header: "الدور",
        cell: ({ row }) => <StatusBadge status={row.original.role} />,
      },
      {
        accessorKey: "createdAt",
        header: "تاريخ التسجيل",
        cell: ({ row }) => formatDate(row.original.createdAt),
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
          const u = row.original;
          return (
            <div className="flex flex-wrap gap-1">
              <Button size="sm" variant="outline" onClick={() => setSelected(u)}>
                عرض
              </Button>
              <Button
                size="sm"
                variant="outline"
                onClick={() =>
                  updateUser(u.id, {
                    city: u.city === "الجزائر العاصمة" || u.city === "Algiers" ? "وهران" : "الجزائر العاصمة",
                  })
                }
              >
                تعديل
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
                {u.status === "suspended" ? "تفعيل" : "إيقاف"}
              </Button>
              <Button
                size="sm"
                variant="destructive"
                onClick={() => {
                  if (confirm(`حذف ${u.name}؟`)) deleteUser(u.id);
                }}
              >
                حذف
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
        title="المستخدمون"
        description="إدارة الزبائن والمؤجّرين الأفراد وأصحاب المحلات."
        actions={
          <select
            className="h-10 rounded-md border border-border bg-card px-3 text-sm"
            value={roleFilter}
            onChange={(e) => setRoleFilter(e.target.value)}
          >
            <option value="all">كل الأدوار</option>
            <option value="customer">زبائن</option>
            <option value="individualOwner">مؤجّرون أفراد</option>
            <option value="storeOwner">أصحاب محلات</option>
          </select>
        }
      />
      <DataTable
        columns={columns}
        data={data}
        searchPlaceholder="ابحث بالاسم أو الهاتف أو البريد…"
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
                <span className="text-muted-foreground">الهاتف:</span>{" "}
                <span dir="ltr">{selected.phone}</span>
              </p>
              <p>
                <span className="text-muted-foreground">البريد:</span>{" "}
                <span dir="ltr">{selected.email}</span>
              </p>
              <p>
                <span className="text-muted-foreground">المدينة:</span>{" "}
                {selected.city}
              </p>
              <p>
                <span className="text-muted-foreground">الدور:</span>{" "}
                {labelOf(roleLabel, selected.role)}
              </p>
              <div className="rounded-lg bg-muted p-3">
                <p className="font-medium">
                  الحجوزات: <span dir="ltr">{userBookings.length}</span>
                </p>
                <p className="font-medium">
                  الفساتين المملوكة: <span dir="ltr">{userDresses.length}</span>
                </p>
                <p className="font-medium">
                  المعاملات: <span dir="ltr">{userTx.length}</span>
                </p>
              </div>
            </div>
          ) : null}
        </DialogContent>
      </Dialog>
    </div>
  );
}
