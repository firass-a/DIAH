"use client";

import { useMemo } from "react";
import type { ColumnDef } from "@tanstack/react-table";
import { PageHeader, StatusBadge } from "@/components/shared";
import { DataTable } from "@/components/tables/data-table";
import { Button } from "@/components/ui/button";
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
      { accessorKey: "id", header: "ID" },
      {
        accessorKey: "bookingId",
        header: "Booking",
        cell: ({ row }) => row.original.bookingId ?? "—",
      },
      {
        id: "customer",
        header: "Customer",
        cell: ({ row }) =>
          users.find((u) => u.id === row.original.customerId)?.name ?? "—",
      },
      {
        accessorKey: "amount",
        header: "Amount",
        cell: ({ row }) => formatCurrency(row.original.amount),
      },
      { accessorKey: "type", header: "Type" },
      {
        accessorKey: "date",
        header: "Date",
        cell: ({ row }) => formatDate(row.original.date),
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
            <Button
              size="sm"
              variant="outline"
              onClick={() => updateStatus(row.original.id, "completed")}
            >
              Complete
            </Button>
            <Button
              size="sm"
              variant="secondary"
              onClick={() => refund(row.original.id)}
              disabled={row.original.status === "refunded"}
            >
              Refund
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
        title="Transactions"
        description="Monitor deposits, rentals, commissions, and refunds."
      />
      <DataTable
        columns={columns}
        data={transactions}
        searchPlaceholder="Search transactions…"
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
