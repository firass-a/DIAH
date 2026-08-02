"use client";

import { create } from "zustand";
import { seedUsers } from "@/lib/mock-data/seed";
import { uid } from "@/lib/utils";
import type { User, UserStatus } from "@/types/user";

interface UserState {
  users: User[];
  addUser: (user: Omit<User, "id" | "createdAt" | "ownedDressIds">) => User;
  updateUser: (id: string, patch: Partial<User>) => void;
  setStatus: (id: string, status: UserStatus) => void;
  deleteUser: (id: string) => void;
  getById: (id: string) => User | undefined;
}

export const useUserStore = create<UserState>((set, get) => ({
  users: seedUsers,
  addUser: (data) => {
    const user: User = {
      ...data,
      id: uid("user"),
      createdAt: new Date().toISOString(),
      ownedDressIds: [],
    };
    set((s) => ({ users: [user, ...s.users] }));
    return user;
  },
  updateUser: (id, patch) =>
    set((s) => ({
      users: s.users.map((u) => (u.id === id ? { ...u, ...patch } : u)),
    })),
  setStatus: (id, status) => get().updateUser(id, { status }),
  deleteUser: (id) =>
    set((s) => ({ users: s.users.filter((u) => u.id !== id) })),
  getById: (id) => get().users.find((u) => u.id === id),
}));
