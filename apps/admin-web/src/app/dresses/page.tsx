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
        header: "Image",
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
      { accessorKey: "name", header: "Name" },
      {
        id: "owner",
        header: "Owner",
        cell: ({ row }) =>
          users.find((u) => u.id === row.original.ownerId)?.name ?? "—",
      },
      {
        id: "store",
        header: "Store",
        cell: ({ row }) =>
          stores.find((s) => s.id === row.original.storeId)?.name ?? "Personal",
      },
      { accessorKey: "category", header: "Category" },
      {
        accessorKey: "price",
        header: "Price",
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
        cell: ({ row }) => {
          const d = row.original;
          return (
            <div className="flex flex-wrap gap-1">
              <Button size="sm" variant="outline" onClick={() => setSelected(d)}>
                View
              </Button>
              <Button size="sm" variant="outline" onClick={() => approveDress(d.id)}>
                Approve
              </Button>
              <Button size="sm" variant="secondary" onClick={() => rejectDress(d.id)}>
                Reject
              </Button>
              <Button size="sm" variant="outline" onClick={() => hideDress(d.id)}>
                Hide
              </Button>
              <Button
                size="sm"
                variant="destructive"
                onClick={() => {
                  if (confirm(`Delete ${d.name}?`)) deleteDress(d.id);
                }}
              >
                Delete
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
        title="Dresses"
        description="Review personal and store inventory listings."
        actions={
          <select
            className="h-10 rounded-md border border-border bg-card px-3 text-sm"
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
          >
            <option value="all">All</option>
            <option value="pending">Pending</option>
            <option value="available">Available</option>
            <option value="rejected">Rejected</option>
            <option value="hidden">Hidden</option>
          </select>
        }
      />
      <DataTable
        columns={columns}
        data={data}
        searchPlaceholder="Search dresses…"
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
                <p>Category: {selected.category}</p>
                <p>Color: {selected.color}</p>
                <p>Size: {selected.size}</p>
                <p>Price: {formatCurrency(selected.price)}</p>
                <p>Deposit: {formatCurrency(selected.deposit)}</p>
                <p>Rentals: {selected.rentalCount}</p>
              </div>
            </div>
          ) : null}
        </DialogContent>
      </Dialog>
    </div>
  );
}
