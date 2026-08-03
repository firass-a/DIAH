/** Arabic display labels. Keep enum keys in English; numbers stay Latin via formatters. */

export const statusLabel: Record<string, string> = {
  active: "نشط",
  pending: "قيد المراجعة",
  suspended: "موقوف",
  approved: "مقبول",
  rejected: "مرفوض",
  available: "متاح",
  completed: "مكتمل",
  verified: "موثّق",
  trial: "تجريبي",
  cancelled: "ملغى",
  failed: "فشل",
  expired: "منتهي",
  hidden: "مخفي",
  refunded: "مسترجع",
  disabled: "معطّل",
  returned: "مُعاد",
};

export const roleLabel: Record<string, string> = {
  customer: "زبون",
  individualOwner: "مؤجّر فردي",
  storeOwner: "صاحب محل",
  admin: "مسؤول",
};

export const storeCategoryLabel: Record<string, string> = {
  wedding: "زفاف",
  evening: "سهرة",
  traditional: "تقليدي",
  mixed: "متنوع",
};

export const dressCategoryLabel: Record<string, string> = {
  Wedding: "زفاف",
  Evening: "سهرة",
  Traditional: "تقليدي",
  Karakou: "كاراكو",
  Caftan: "قفطان",
  Accessories: "إكسسوارات",
};

export const bookingStatusLabel: Record<string, string> = {
  pending: "قيد الانتظار",
  approved: "مقبول",
  rejected: "مرفوض",
  completed: "مكتمل",
  cancelled: "ملغى",
  returned: "مُعاد",
};

export const transactionTypeLabel: Record<string, string> = {
  rental: "إيجار",
  deposit: "تأمين",
  refund: "استرجاع",
  commission: "عمولة",
  subscription: "اشتراك",
};

export const planLabel: Record<string, string> = {
  monthly: "شهري",
  yearly: "سنوي",
  trial: "تجريبي",
};

export const notificationTargetLabel: Record<string, string> = {
  all: "الجميع",
  customers: "الزبائن",
  owners: "المؤجّرون",
  stores: "المحلات",
};

export function labelOf(
  map: Record<string, string>,
  key: string | null | undefined,
  fallback?: string,
) {
  if (!key) return fallback ?? "—";
  return map[key] ?? fallback ?? key;
}
