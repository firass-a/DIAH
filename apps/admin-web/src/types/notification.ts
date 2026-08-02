export type NotificationTarget = "all" | "customers" | "owners" | "stores";

export interface AdminNotification {
  id: string;
  title: string;
  message: string;
  target: NotificationTarget;
  createdAt: string;
}
