export type BookingStatus =
  | "pending"
  | "approved"
  | "rejected"
  | "completed"
  | "cancelled"
  | "returned";

export interface Booking {
  id: string;
  customerId: string;
  dressId: string;
  storeId?: string;
  startDate: string;
  endDate: string;
  price: number;
  deposit: number;
  status: BookingStatus;
  createdAt: string;
}
