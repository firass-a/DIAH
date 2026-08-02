"use client";

import { create } from "zustand";
import { seedSubscriptions } from "@/lib/mock-data/seed";
import type { Subscription, SubscriptionStatus } from "@/types/subscription";

interface SubscriptionState {
  subscriptions: Subscription[];
  updateSubscription: (id: string, patch: Partial<Subscription>) => void;
  setStatus: (id: string, status: SubscriptionStatus) => void;
  renew: (id: string) => void;
}

export const useSubscriptionStore = create<SubscriptionState>((set, get) => ({
  subscriptions: seedSubscriptions,
  updateSubscription: (id, patch) =>
    set((s) => ({
      subscriptions: s.subscriptions.map((sub) =>
        sub.id === id ? { ...sub, ...patch } : sub,
      ),
    })),
  setStatus: (id, status) => get().updateSubscription(id, { status }),
  renew: (id) => {
    const sub = get().subscriptions.find((s) => s.id === id);
    if (!sub) return;
    const end = new Date();
    end.setDate(end.getDate() + (sub.plan === "yearly" ? 365 : 30));
    get().updateSubscription(id, {
      status: "active",
      startDate: new Date().toISOString().slice(0, 10),
      endDate: end.toISOString().slice(0, 10),
    });
  },
}));
