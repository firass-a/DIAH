"use client";

import { create } from "zustand";
import { seedTransactions } from "@/lib/mock-data/seed";
import { uid } from "@/lib/utils";
import type { Transaction, TransactionStatus } from "@/types/transaction";

interface TransactionState {
  transactions: Transaction[];
  updateStatus: (id: string, status: TransactionStatus) => void;
  refund: (id: string) => void;
  addTransaction: (tx: Omit<Transaction, "id" | "date">) => void;
}

export const useTransactionStore = create<TransactionState>((set) => ({
  transactions: seedTransactions,
  updateStatus: (id, status) =>
    set((s) => ({
      transactions: s.transactions.map((t) =>
        t.id === id ? { ...t, status } : t,
      ),
    })),
  refund: (id) =>
    set((s) => {
      const original = s.transactions.find((t) => t.id === id);
      if (!original) return s;
      const refundTx: Transaction = {
        ...original,
        id: uid("tx"),
        type: "refund",
        status: "refunded",
        date: new Date().toISOString(),
        description: `Refund of ${original.id}`,
        amount: original.amount,
      };
      return {
        transactions: [
          refundTx,
          ...s.transactions.map((t) =>
            t.id === id ? { ...t, status: "refunded" as const } : t,
          ),
        ],
      };
    }),
  addTransaction: (tx) =>
    set((s) => ({
      transactions: [
        { ...tx, id: uid("tx"), date: new Date().toISOString() },
        ...s.transactions,
      ],
    })),
}));
