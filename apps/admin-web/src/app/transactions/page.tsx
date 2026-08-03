"use client";

import { useMemo } from "react";
import type { ColumnDef } from "@tanstack/react-table";
import { PageHeader, StatusBadge } from "@/components/shared";
import { DataTable } from "@/components/tables/data-table";
import { Button } from "@/components/ui/button";
import { labelOf, transactionTypeLabel } from "@/lib/labels";
import { formatCurrency, formatDate } from "@/lib/utils";
import { useTransactionStore } from "@/stores/transaction-store";
import { useUserStore } from "@/stores/user-store";
import type { Transaction } from "@/types/transaction";

export default function TransactionsPage() {
  const transactions = useTransactionStore((s) => s.transactions);
  const updateStatus = useTransactionStore((s) => s.updateStatus);
  const refund = useTransactionStore((s) => s.refund);
  const users = useUserStore((s) => s.users);

  const columns = useMemo<ColumnDef<Transaction>[]>(
    () => [
      {
        accessorKey: "id",
        header: "المعرّف",
        cell: ({ row }) => <span dir="ltr">{row.original.id}</span>,
      },
      {
        accessorKey: "bookingId",
        header: "الحجز",
        cell: ({ row }) => (
          <span dir="ltr">{row.original.bookingId ?? "—"}</span>
        ),
      },
      {
        id: "customer",
        header: "الزبون",
        cell: ({ row }) =>
          users.find((u) => u.id === row.original.customerId)?.name ?? "—",
      },
      {
        accessorKey: "amount",
        header: "المبلغ",
        cell: ({ row }) => (
          <span dir="ltr">{formatCurrency(row.original.amount)}</span>
        ),
      },
      {
        accessorKey: "type",
        header: "النوع",
        cell: ({ row }) =>
          labelOf(transactionTypeLabel, row.original.type),
      },
      {
        accessorKey: "date",
        header: "التاريخ",
        cell: ({ row }) => formatDate(row.original.date),
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
              onClick={() => updateStatus(row.original.id, "completed")}
            >
              إتمام
            </Button>
            <Button
              size="sm"
              variant="secondary"
              onClick={() => refund(row.original.id)}
              disabled={row.original.status === "refunded"}
            >
              استرجاع
            </Button>
          </div>
        ),
      },
    ],
    [refund, updateStatus, users],
  );

  return (
    <div>
      <PageHeader
        title="المعاملات"
        description="متابعة التأمينات والإيجارات والعمولات والاسترجاعات."
      />
      <DataTable
        columns={columns}
        data={transactions}
        searchPlaceholder="ابحث في المعاملات…"
        globalFilterFn={(row, q) =>
          [row.id, row.type, row.status, row.description, row.bookingId]
            .join(" ")
            .toLowerCase()
            .includes(q)
        }
      />
    </div>
  );
}
