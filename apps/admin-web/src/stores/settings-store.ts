"use client";

import { create } from "zustand";
import { persist } from "zustand/middleware";
import { seedSettings } from "@/lib/mock-data/seed";
import type { PlatformSettings } from "@/types/settings";

interface SettingsState {
  settings: PlatformSettings;
  updateSettings: (patch: Partial<PlatformSettings>) => void;
  addCategory: (name: string) => void;
  removeCategory: (name: string) => void;
  addDressType: (name: string) => void;
  removeDressType: (name: string) => void;
}

export const useSettingsStore = create<SettingsState>()(
  persist(
    (set) => ({
      settings: seedSettings,
      updateSettings: (patch) =>
        set((s) => ({ settings: { ...s.settings, ...patch } })),
      addCategory: (name) =>
        set((s) => ({
          settings: {
            ...s.settings,
            categories: s.settings.categories.includes(name)
              ? s.settings.categories
              : [...s.settings.categories, name],
          },
        })),
      removeCategory: (name) =>
        set((s) => ({
          settings: {
            ...s.settings,
            categories: s.settings.categories.filter((c) => c !== name),
          },
        })),
      addDressType: (name) =>
        set((s) => ({
          settings: {
            ...s.settings,
            dressTypes: s.settings.dressTypes.includes(name)
              ? s.settings.dressTypes
              : [...s.settings.dressTypes, name],
          },
        })),
      removeDressType: (name) =>
        set((s) => ({
          settings: {
            ...s.settings,
            dressTypes: s.settings.dressTypes.filter((t) => t !== name),
          },
        })),
    }),
    { name: "diah-admin-settings" },
  ),
);
