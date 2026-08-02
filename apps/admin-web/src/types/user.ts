export type UserRole = "customer" | "individualOwner" | "storeOwner" | "admin";
export type UserStatus = "active" | "suspended" | "pending";

export interface User {
  id: string;
  name: string;
  phone: string;
  email: string;
  role: UserRole;
  status: UserStatus;
  city: string;
  avatar?: string;
  createdAt: string;
  ownedDressIds: string[];
}
