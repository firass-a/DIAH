export type SubscriptionPlan = "monthly" | "yearly" | "trial";
export type SubscriptionStatus = "active" | "expired" | "cancelled" | "trial";

export interface Subscription {
  id: string;
  storeId: string;
  plan: SubscriptionPlan;
  price: number;
  startDate: string;
  endDate: string;
  status: SubscriptionStatus;
}
