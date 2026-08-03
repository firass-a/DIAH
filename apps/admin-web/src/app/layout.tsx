import type { Metadata } from "next";
import { Cairo, Noto_Naskh_Arabic } from "next/font/google";
import { AdminShell } from "@/components/layout/admin-shell";
import "./globals.css";

const cairo = Cairo({
  subsets: ["arabic", "latin"],
  variable: "--font-cairo",
});

const naskh = Noto_Naskh_Arabic({
  subsets: ["arabic"],
  weight: ["500", "600", "700"],
  variable: "--font-naskh",
});

export const metadata: Metadata = {
  title: "لوحة دِياه",
  description: "لوحة إدارة منصة دِياه",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ar" dir="rtl">
      <body className={`${cairo.variable} ${naskh.variable} font-sans antialiased`}>
        <AdminShell>{children}</AdminShell>
      </body>
    </html>
  );
}
