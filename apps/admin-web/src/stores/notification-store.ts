"use client";

import { create } from "zustand";
import { seedNotifications } from "@/lib/mock-data/seed";
import { uid } from "@/lib/utils";
import type { AdminNotification, NotificationTarget } from "@/types/notification";

interface NotificationState {
  notifications: AdminNotification[];
  createNotification: (data: {
    title: string;
    message: string;
    target: NotificationTarget;
  }) => void;
  deleteNotification: (id: string) => void;
}

export const useNotificationStore = create<NotificationState>((set) => ({
  notifications: seedNotifications,
  createNotification: (data) =>
    set((s) => ({
      notifications: [
        {
          id: uid("notif"),
          ...data,
          createdAt: new Date().toISOString(),
        },
        ...s.notifications,
      ],
    })),
  deleteNotification: (id) =>
    set((s) => ({
      notifications: s.notifications.filter((n) => n.id !== id),
    })),
}));
