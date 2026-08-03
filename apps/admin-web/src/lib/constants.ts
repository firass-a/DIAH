export const BRAND = {
  primary: "#887893",
  background: "#F8F5FA",
  card: "#FFFFFF",
  accent: "#B2A0B7",
  text: "#111111",
} as const;

export const ADMIN_DEMO = {
  email: "admin@diah.dz",
  password: "admin123",
  name: "مسؤول دِياه",
} as const;

export const NAV_ITEMS = [
  { href: "/dashboard", label: "لوحة التحكم", icon: "LayoutDashboard" },
  { href: "/users", label: "المستخدمون", icon: "Users" },
  { href: "/stores", label: "المحلات", icon: "Store" },
  { href: "/dresses", label: "الفساتين", icon: "Shirt" },
  { href: "/bookings", label: "الحجوزات", icon: "CalendarDays" },
  { href: "/transactions", label: "المعاملات", icon: "Wallet" },
  { href: "/subscriptions", label: "الاشتراكات", icon: "CreditCard" },
  { href: "/analytics", label: "التحليلات", icon: "BarChart3" },
  { href: "/notifications", label: "الإشعارات", icon: "Bell" },
  { href: "/settings", label: "الإعدادات", icon: "Settings" },
] as const;

export const DRESS_CATEGORIES = [
  "Wedding",
  "Evening",
  "Traditional",
  "Karakou",
  "Caftan",
  "Accessories",
] as const;

export const SUBSCRIPTION_PLANS = [
  { id: "monthly", name: "شهري", price: 9000 },
  { id: "yearly", name: "سنوي", price: 90000 },
  { id: "trial", name: "تجريبي", price: 0 },
] as const;
