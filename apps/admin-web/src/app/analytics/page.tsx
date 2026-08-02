"use client";

import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Line,
  LineChart,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { ChartCard, DashboardCard, PageHeader } from "@/components/shared";
import { seedMonthlyStats } from "@/lib/mock-data/seed";
import { formatCurrency } from "@/lib/utils";
import { useBookingStore } from "@/stores/booking-store";
import { useDressStore } from "@/stores/dress-store";
import { useStoreStore } from "@/stores/store-store";
import { useTransactionStore } from "@/stores/transaction-store";
import { useUserStore } from "@/stores/user-store";

const COLORS = ["#887893", "#B2A0B7", "#6B5B7A", "#D4C4DC"];

export default function AnalyticsPage() {
  const users = useUserStore((s) => s.users);
  const stores = useStoreStore((s) => s.stores);
  const dresses = useDressStore((s) => s.dresses);
  const bookings = useBookingStore((s) => s.bookings);
  const transactions = useTransactionStore((s) => s.transactions);

  const revenue = transactions
    .filter((t) => t.status === "completed" && t.type !== "refund")
    .reduce((s, t) => s + t.amount, 0);

  const rolePie = Object.entries(
    users.reduce<Record<string, number>>((acc, u) => {
      acc[u.role] = (acc[u.role] ?? 0) + 1;
      return acc;
    }, {}),
  ).map(([name, value]) => ({ name, value }));

  const bookingStatus = Object.entries(
    bookings.reduce<Record<string, number>>((acc, b) => {
      acc[b.status] = (acc[b.status] ?? 0) + 1;
      return acc;
    }, {}),
  ).map(([name, value]) => ({ name, value }));

  return (
    <div>
      <PageHeader
        title="Analytics"
        description="Deeper performance views powered by live Zustand state."
      />
      <div className="mb-6 grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <DashboardCard title="Revenue" value={formatCurrency(revenue)} />
        <DashboardCard title="Users" value={users.length} />
        <DashboardCard title="Stores" value={stores.length} />
        <DashboardCard title="Catalog size" value={dresses.length} />
      </div>
      <div className="grid gap-4 xl:grid-cols-2">
        <ChartCard title="Revenue analytics">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={seedMonthlyStats}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e6e0ea" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip />
              <Line type="monotone" dataKey="revenue" stroke="#887893" strokeWidth={2.5} />
            </LineChart>
          </ResponsiveContainer>
        </ChartCard>
        <ChartCard title="Booking analytics">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={bookingStatus}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e6e0ea" />
              <XAxis dataKey="name" />
              <YAxis allowDecimals={false} />
              <Tooltip />
              <Bar dataKey="value" fill="#B2A0B7" radius={[6, 6, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </ChartCard>
        <ChartCard title="User analytics">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie data={rolePie} dataKey="value" nameKey="name" outerRadius={90} label>
                {rolePie.map((_, i) => (
                  <Cell key={i} fill={COLORS[i % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip />
            </PieChart>
          </ResponsiveContainer>
        </ChartCard>
        <ChartCard title="Store analytics">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart
              data={stores.map((s) => ({
                name: s.name.split(" ")[0],
                dresses: dresses.filter((d) => d.storeId === s.id).length,
              }))}
            >
              <CartesianGrid strokeDasharray="3 3" stroke="#e6e0ea" />
              <XAxis dataKey="name" />
              <YAxis allowDecimals={false} />
              <Tooltip />
              <Bar dataKey="dresses" fill="#6B5B7A" radius={[6, 6, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </ChartCard>
      </div>
    </div>
  );
}
