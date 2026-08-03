"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { ADMIN_DEMO } from "@/lib/constants";
import { useAuthStore } from "@/stores/auth-store";

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(4),
});

type FormValues = z.infer<typeof schema>;

export default function LoginPage() {
  const router = useRouter();
  const login = useAuthStore((s) => s.login);
  const [error, setError] = useState<string | null>(null);
  const form = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { email: ADMIN_DEMO.email, password: ADMIN_DEMO.password },
  });

  const onSubmit = (values: FormValues) => {
    const result = login(values.email, values.password);
    if (!result.ok) {
      setError(result.error ?? "فشل تسجيل الدخول");
      return;
    }
    router.replace("/dashboard");
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-[radial-gradient(circle_at_top,_#efe7f3,_#f8f5fa_45%)] p-4">
      <Card className="w-full max-w-md border-border/80 shadow-lg">
        <CardHeader className="space-y-3 text-center">
          <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-2xl bg-primary text-lg font-bold text-white">
            D
          </div>
          <CardTitle className="text-3xl">لوحة دِياه</CardTitle>
          <p className="text-sm text-muted-foreground">
            سجّل الدخول لإدارة منصة السوق
          </p>
        </CardHeader>
        <CardContent>
          <form className="space-y-4" onSubmit={form.handleSubmit(onSubmit)}>
            <div className="space-y-2">
              <Label htmlFor="email">البريد الإلكتروني</Label>
              <Input
                id="email"
                type="email"
                dir="ltr"
                {...form.register("email")}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="password">كلمة المرور</Label>
              <Input
                id="password"
                type="password"
                dir="ltr"
                {...form.register("password")}
              />
            </div>
            {error ? (
              <p className="text-sm text-destructive">{error}</p>
            ) : null}
            <Button type="submit" className="w-full">
              تسجيل الدخول
            </Button>
            <p className="text-center text-xs text-muted-foreground" dir="ltr">
              تجريبي: {ADMIN_DEMO.email} / {ADMIN_DEMO.password}
            </p>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
