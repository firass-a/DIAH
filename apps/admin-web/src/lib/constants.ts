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
  name: "Diah Admin",
} as const;

export const NAV_ITEMS = [
  { href: "/dashboard", label: "Dashboard", icon: "LayoutDashboard" },
  { href: "/users", label: "Users", icon: "Users" },
  { href: "/stores", label: "Stores", icon: "Store" },
  { href: "/dresses", label: "Dresses", icon: "Shirt" },
  { href: "/bookings", label: "Bookings", icon: "CalendarDays" },
  { href: "/transactions", label: "Transactions", icon: "Wallet" },
  { href: "/subscriptions", label: "Subscriptions", icon: "CreditCard" },
  { href: "/analytics", label: "Analytics", icon: "BarChart3" },
  { href: "/notifications", label: "Notifications", icon: "Bell" },
  { href: "/settings", label: "Settings", icon: "Settings" },
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
  { id: "monthly", name: "Monthly", price: 9000 },
  { id: "yearly", name: "Yearly", price: 90000 },
  { id: "trial", name: "Trial", price: 0 },
] as const;
