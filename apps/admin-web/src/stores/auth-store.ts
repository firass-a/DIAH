"use client";

import { create } from "zustand";
import { persist } from "zustand/middleware";
import { ADMIN_DEMO } from "@/lib/constants";

interface AuthState {
  isAuthenticated: boolean;
  email: string | null;
  name: string | null;
  login: (email: string, password: string) => { ok: boolean; error?: string };
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      isAuthenticated: false,
      email: null,
      name: null,
      login: (email, password) => {
        if (
          email.trim().toLowerCase() === ADMIN_DEMO.email &&
          password === ADMIN_DEMO.password
        ) {
          set({
            isAuthenticated: true,
            email: ADMIN_DEMO.email,
            name: ADMIN_DEMO.name,
          });
          return { ok: true };
        }
        return {
          ok: false,
          error: "بيانات الدخول غير صحيحة. استخدم admin@diah.dz / admin123",
        };
      },
      logout: () => set({ isAuthenticated: false, email: null, name: null }),
    }),
    { name: "diah-admin-auth" },
  ),
);
