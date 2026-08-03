"use client";

import { useState } from "react";
import { PageHeader } from "@/components/shared";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { dressCategoryLabel } from "@/lib/labels";
import { useSettingsStore } from "@/stores/settings-store";

export default function SettingsPage() {
  const settings = useSettingsStore((s) => s.settings);
  const updateSettings = useSettingsStore((s) => s.updateSettings);
  const addCategory = useSettingsStore((s) => s.addCategory);
  const removeCategory = useSettingsStore((s) => s.removeCategory);
  const addDressType = useSettingsStore((s) => s.addDressType);
  const removeDressType = useSettingsStore((s) => s.removeDressType);
  const [category, setCategory] = useState("");
  const [dressType, setDressType] = useState("");
  const [saved, setSaved] = useState(false);

  return (
    <div>
      <PageHeader
        title="الإعدادات"
        description="ضبط فئات السوق وقواعد التسعير والتنبيهات."
      />
      <div className="grid gap-4 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">الفئات</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="flex flex-wrap gap-2">
              {settings.categories.map((c) => (
                <button
                  key={c}
                  className="rounded-full bg-muted px-3 py-1 text-xs"
                  onClick={() => removeCategory(c)}
                  title="إزالة"
                >
                  {dressCategoryLabel[c] ?? c} ×
                </button>
              ))}
            </div>
            <div className="flex gap-2">
              <Input
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                placeholder="فئة جديدة"
              />
              <Button
                onClick={() => {
                  if (!category.trim()) return;
                  addCategory(category.trim());
                  setCategory("");
                }}
              >
                إضافة
              </Button>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-lg">أنواع الفساتين</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="flex flex-wrap gap-2">
              {settings.dressTypes.map((t) => (
                <button
                  key={t}
                  className="rounded-full bg-muted px-3 py-1 text-xs"
                  onClick={() => removeDressType(t)}
                >
                  {t} ×
                </button>
              ))}
            </div>
            <div className="flex gap-2">
              <Input
                value={dressType}
                onChange={(e) => setDressType(e.target.value)}
                placeholder="نوع فستان جديد"
              />
              <Button
                onClick={() => {
                  if (!dressType.trim()) return;
                  addDressType(dressType.trim());
                  setDressType("");
                }}
              >
                إضافة
              </Button>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-lg">قواعد التسعير</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="space-y-1.5">
              <Label>العمولة (%)</Label>
              <Input
                type="number"
                dir="ltr"
                value={settings.commissionPercent}
                onChange={(e) =>
                  updateSettings({
                    commissionPercent: Number(e.target.value) || 0,
                  })
                }
              />
            </div>
            <div className="space-y-1.5">
              <Label>التأمين الافتراضي (%)</Label>
              <Input
                type="number"
                dir="ltr"
                value={settings.defaultDepositPercent}
                onChange={(e) =>
                  updateSettings({
                    defaultDepositPercent: Number(e.target.value) || 0,
                  })
                }
              />
            </div>
            <div className="space-y-1.5">
              <Label>العملة</Label>
              <Input
                dir="ltr"
                value={settings.currency}
                onChange={(e) => updateSettings({ currency: e.target.value })}
              />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-lg">إعدادات الإشعارات</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="space-y-1.5">
              <Label>بريد الدعم</Label>
              <Input
                dir="ltr"
                value={settings.supportEmail}
                onChange={(e) =>
                  updateSettings({ supportEmail: e.target.value })
                }
              />
            </div>
            {(
              [
                ["notifyNewUsers", "تنبيه عند مستخدمين جدد"],
                ["notifyNewStores", "تنبيه عند محلات جديدة"],
                ["notifyPendingDresses", "تنبيه عند فساتين قيد المراجعة"],
              ] as const
            ).map(([key, label]) => (
              <label key={key} className="flex items-center gap-2 text-sm">
                <input
                  type="checkbox"
                  checked={settings[key]}
                  onChange={(e) => updateSettings({ [key]: e.target.checked })}
                />
                {label}
              </label>
            ))}
            <Button
              onClick={() => {
                setSaved(true);
                setTimeout(() => setSaved(false), 1500);
              }}
            >
              حفظ الإعدادات
            </Button>
            {saved ? (
              <p className="text-xs text-success">تم الحفظ محلياً</p>
            ) : null}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
