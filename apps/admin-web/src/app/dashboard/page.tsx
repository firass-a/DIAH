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
import {
  CalendarDays,
  Shirt,
  Store,
  Users,
  Wallet,
  CreditCard,
} from "lucide-react";
import { ChartCard, DashboardCard, PageHeader, StatusBadge } from "@/components/shared";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { dressCategoryLabel } from "@/lib/labels";
import { seedMonthlyStats } from "@/lib/mock-data/seed";
import { formatCurrency, formatDate } from "@/lib/utils";
import { useBookingStore } from "@/stores/booking-store";
import { useDressStore } from "@/stores/dress-store";
import { useStoreStore } from "@/stores/store-store";
import { useSubscriptionStore } from "@/stores/subscription-store";
import { useTransactionStore } from "@/stores/transaction-store";
import { useUserStore } from "@/stores/user-store";

const PIE_COLORS = ["#887893", "#B2A0B7", "#6B5B7A", "#D4C4DC", "#9B7E9F"];

export default function DashboardPage() {
  const users = useUserStore((s) => s.users);
  const stores = useStoreStore((s) => s.stores);
  const dresses = useDressStore((s) => s.dresses);
  const bookings = useBookingStore((s) => s.bookings);
  const transactions = useTransactionStore((s) => s.transactions);
  const subscriptions = useSubscriptionStore((s) => s.subscriptions);

  const customers = users.filter((u) => u.role === "customer").length;
  const revenue = transactions
    .filter((t) => t.status === "completed" && t.type !== "refund")
    .reduce((sum, t) => sum + t.amount, 0);
  const activeSubs = subscriptions.filter(
    (s) => s.status === "active" || s.status === "trial",
  ).length;

  const categoryData = Object.entries(
    dresses.reduce<Record<string, number>>((acc, d) => {
      acc[d.category] = (acc[d.category] ?? 0) + 1;
      return acc;
    }, {}),
  ).map(([name, value]) => ({
    name: dressCategoryLabel[name] ?? name,
    value,
  }));

  const topDresses = [...dresses]
    .sort((a, b) => b.rentalCount - a.rentalCount)
    .slice(0, 5);

  return (
    <div>
      <PageHeader
        title="لوحة التحكم"
        description="نظرة مباشرة على سوق دِياه (بيانات تجريبية محلية)."
      />

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <DashboardCard title="إجمالي المستخدمين" value={users.length} icon={<Users className="h-4 w-4" />} />
        <DashboardCard title="الزبائن" value={customers} icon={<Users className="h-4 w-4" />} />
        <DashboardCard title="المحلات" value={stores.length} icon={<Store className="h-4 w-4" />} />
        <DashboardCard title="الفساتين" value={dresses.length} icon={<Shirt className="h-4 w-4" />} />
        <DashboardCard title="الحجوزات" value={bookings.length} icon={<CalendarDays className="h-4 w-4" />} />
        <DashboardCard title="الإيرادات" value={formatCurrency(revenue)} icon={<Wallet className="h-4 w-4" />} />
        <DashboardCard
          title="الاشتراكات النشطة"
          value={activeSubs}
          icon={<CreditCard className="h-4 w-4" />}
        />
        <DashboardCard
          title="فساتين قيد المراجعة"
          value={dresses.filter((d) => d.status === "pending").length}
          hint="بانتظار الموافقة"
        />
      </div>

      <div className="mt-6 grid gap-4 xl:grid-cols-2">
        <ChartCard title="الإيرادات عبر الزمن">
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
        <ChartCard title="الحجوزات عبر الزمن">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={seedMonthlyStats}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e6e0ea" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip />
              <Bar dataKey="bookings" fill="#B2A0B7" radius={[6, 6, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </ChartCard>
        <ChartCard title="نمو المستخدمين">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={seedMonthlyStats}>
              <CartesianGrid strokeDasharray="3 3" stroke="#e6e0ea" />
              <XAxis dataKey="month" />
              <YAxis />
              <Tooltip />
              <Line type="monotone" dataKey="users" stroke="#6B5B7A" strokeWidth={2.5} />
            </LineChart>
          </ResponsiveContainer>
        </ChartCard>
        <ChartCard title="الفئات الأكثر شيوعاً">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie data={categoryData} dataKey="value" nameKey="name" outerRadius={90} label>
                {categoryData.map((_, i) => (
                  <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />
                ))}
              </Pie>
              <Tooltip />
            </PieChart>
          </ResponsiveContainer>
        </ChartCard>
      </div>

      <div className="mt-6 grid gap-4 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">الأكثر إيجاراً</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            {topDresses.map((d) => (
              <div key={d.id} className="flex items-center justify-between gap-3">
                <div className="min-w-0">
                  <p className="truncate font-medium">{d.name}</p>
                  <p className="text-xs text-muted-foreground">
                    {dressCategoryLabel[d.category] ?? d.category}
                  </p>
                </div>
                <p className="text-sm font-semibold" dir="ltr">
                  {d.rentalCount}×
                </p>
              </div>
            ))}
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">آخر النشاطات</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            {[...users]
              .sort((a, b) => +new Date(b.createdAt) - +new Date(a.createdAt))
              .slice(0, 3)
              .map((u) => (
                <div key={u.id} className="flex items-center justify-between">
                  <div>
                    <p className="font-medium">مستخدم جديد · {u.name}</p>
                    <p className="text-xs text-muted-foreground">{formatDate(u.createdAt)}</p>
                  </div>
                  <StatusBadge status={u.role} />
                </div>
              ))}
            {[...bookings]
              .sort((a, b) => +new Date(b.createdAt) - +new Date(a.createdAt))
              .slice(0, 3)
              .map((b) => (
                <div key={b.id} className="flex items-center justify-between">
                  <div>
                    <p className="font-medium">
                      حجز · <span dir="ltr">{b.id}</span>
                    </p>
                    <p className="text-xs text-muted-foreground">{formatDate(b.createdAt)}</p>
                  </div>
                  <StatusBadge status={b.status} />
                </div>
              ))}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
