"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { PageHeader, StatusBadge } from "@/components/shared";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { formatDateTime } from "@/lib/utils";
import { useNotificationStore } from "@/stores/notification-store";
import type { NotificationTarget } from "@/types/notification";

const schema = z.object({
  title: z.string().min(2),
  message: z.string().min(4),
  target: z.enum(["all", "customers", "owners", "stores"]),
});

type FormValues = z.infer<typeof schema>;

export default function NotificationsPage() {
  const notifications = useNotificationStore((s) => s.notifications);
  const createNotification = useNotificationStore((s) => s.createNotification);
  const deleteNotification = useNotificationStore((s) => s.deleteNotification);
  const [ok, setOk] = useState(false);

  const form = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { title: "", message: "", target: "all" },
  });

  return (
    <div>
      <PageHeader
        title="الإشعارات"
        description="إرسال رسائل المنصة إلى شرائح المستخدمين."
      />
      <div className="grid gap-6 lg:grid-cols-[360px_1fr]">
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">إنشاء إشعار</CardTitle>
          </CardHeader>
          <CardContent>
            <form
              className="space-y-3"
              onSubmit={form.handleSubmit((values) => {
                createNotification({
                  title: values.title,
                  message: values.message,
                  target: values.target as NotificationTarget,
                });
                form.reset({ title: "", message: "", target: "all" });
                setOk(true);
                setTimeout(() => setOk(false), 1600);
              })}
            >
              <div className="space-y-1.5">
                <Label>العنوان</Label>
                <Input {...form.register("title")} />
              </div>
              <div className="space-y-1.5">
                <Label>الرسالة</Label>
                <textarea
                  className="min-h-24 w-full rounded-md border border-border bg-card px-3 py-2 text-sm"
                  {...form.register("message")}
                />
              </div>
              <div className="space-y-1.5">
                <Label>الجمهور</Label>
                <select
                  className="h-10 w-full rounded-md border border-border bg-card px-3 text-sm"
                  {...form.register("target")}
                >
                  <option value="all">الجميع</option>
                  <option value="customers">الزبائن</option>
                  <option value="owners">المؤجّرون</option>
                  <option value="stores">المحلات</option>
                </select>
              </div>
              <Button type="submit" className="w-full">
                إرسال الإشعار
              </Button>
              {ok ? (
                <p className="text-center text-xs text-success">تم الإنشاء</p>
              ) : null}
            </form>
          </CardContent>
        </Card>

        <div className="space-y-3">
          {notifications.map((n) => (
            <Card key={n.id}>
              <CardContent className="flex items-start justify-between gap-4 p-5">
                <div>
                  <div className="mb-2 flex items-center gap-2">
                    <p className="font-medium">{n.title}</p>
                    <StatusBadge status={n.target} />
                  </div>
                  <p className="text-sm text-muted-foreground">{n.message}</p>
                  <p className="mt-2 text-xs text-muted-foreground">
                    {formatDateTime(n.createdAt)}
                  </p>
                </div>
                <Button
                  size="sm"
                  variant="destructive"
                  onClick={() => deleteNotification(n.id)}
                >
                  حذف
                </Button>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    </div>
  );
}
