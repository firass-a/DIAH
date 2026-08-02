"use client";

import { create } from "zustand";
import { seedStores } from "@/lib/mock-data/seed";
import type { Store, StoreStatus } from "@/types/store";

interface StoreState {
  stores: Store[];
  updateStore: (id: string, patch: Partial<Store>) => void;
  setStatus: (id: string, status: StoreStatus) => void;
  deleteStore: (id: string) => void;
  getById: (id: string) => Store | undefined;
}

export const useStoreStore = create<StoreState>((set, get) => ({
  stores: seedStores,
  updateStore: (id, patch) =>
    set((s) => ({
      stores: s.stores.map((st) => (st.id === id ? { ...st, ...patch } : st)),
    })),
  setStatus: (id, status) => get().updateStore(id, { status }),
  deleteStore: (id) =>
    set((s) => ({ stores: s.stores.filter((st) => st.id !== id) })),
  getById: (id) => get().stores.find((st) => st.id === id),
}));
