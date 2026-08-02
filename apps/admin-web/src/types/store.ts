export type StoreStatus = "pending" | "approved" | "rejected" | "suspended" | "active";
export type StoreCategory = "wedding" | "evening" | "traditional" | "mixed";

export interface Store {
  id: string;
  name: string;
  ownerId: string;
  address: string;
  city: string;
  category: StoreCategory;
  subscriptionId?: string;
  status: StoreStatus;
  phone: string;
  logo?: string;
  coverImage?: string;
  createdAt: string;
}
