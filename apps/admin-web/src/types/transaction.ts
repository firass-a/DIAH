export type TransactionType = "rental" | "deposit" | "refund" | "commission" | "subscription";
export type TransactionStatus = "pending" | "completed" | "failed" | "refunded";

export interface Transaction {
  id: string;
  bookingId?: string;
  storeId?: string;
  customerId?: string;
  amount: number;
  type: TransactionType;
  status: TransactionStatus;
  date: string;
  description: string;
}
