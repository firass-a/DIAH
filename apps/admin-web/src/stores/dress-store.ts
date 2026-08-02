"use client";

import { create } from "zustand";
import { seedDresses } from "@/lib/mock-data/seed";
import { uid } from "@/lib/utils";
import type { Dress, DressStatus } from "@/types/dress";

interface DressState {
  dresses: Dress[];
  addDress: (dress: Omit<Dress, "id" | "createdAt" | "rentalCount">) => Dress;
  updateDress: (id: string, patch: Partial<Dress>) => void;
  setStatus: (id: string, status: DressStatus) => void;
  approveDress: (id: string) => void;
  rejectDress: (id: string) => void;
  hideDress: (id: string) => void;
  deleteDress: (id: string) => void;
  getById: (id: string) => Dress | undefined;
}

export const useDressStore = create<DressState>((set, get) => ({
  dresses: seedDresses,
  addDress: (data) => {
    const dress: Dress = {
      ...data,
      id: uid("dress"),
      createdAt: new Date().toISOString(),
      rentalCount: 0,
    };
    set((s) => ({ dresses: [dress, ...s.dresses] }));
    return dress;
  },
  updateDress: (id, patch) =>
    set((s) => ({
      dresses: s.dresses.map((d) => (d.id === id ? { ...d, ...patch } : d)),
    })),
  setStatus: (id, status) => get().updateDress(id, { status }),
  approveDress: (id) => get().setStatus(id, "available"),
  rejectDress: (id) => get().setStatus(id, "rejected"),
  hideDress: (id) => get().setStatus(id, "hidden"),
  deleteDress: (id) =>
    set((s) => ({ dresses: s.dresses.filter((d) => d.id !== id) })),
  getById: (id) => get().dresses.find((d) => d.id === id),
}));
