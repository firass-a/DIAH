export type DressStatus =
  | "pending"
  | "approved"
  | "rejected"
  | "hidden"
  | "available"
  | "rented";

export interface Dress {
  id: string;
  name: string;
  description: string;
  images: string[];
  category: string;
  color: string;
  size: string;
  price: number;
  deposit: number;
  status: DressStatus;
  ownerId: string;
  storeId?: string;
  rentalCount: number;
  createdAt: string;
}
