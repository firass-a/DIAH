"use client";

import { useState } from "react";
import { PageHeader } from "@/components/shared";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
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
        title="Settings"
        description="Configure marketplace categories, pricing rules, and alerts."
      />
      <div className="grid gap-4 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Categories</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="flex flex-wrap gap-2">
              {settings.categories.map((c) => (
                <button
                  key={c}
                  className="rounded-full bg-muted px-3 py-1 text-xs"
                  onClick={() => removeCategory(c)}
                  title="Remove"
                >
                  {c} ×
                </button>
              ))}
            </div>
            <div className="flex gap-2">
              <Input
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                placeholder="New category"
              />
              <Button
                onClick={() => {
                  if (!category.trim()) return;
                  addCategory(category.trim());
                  setCategory("");
                }}
              >
                Add
              </Button>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Dress types</CardTitle>
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
                placeholder="New dress type"
              />
              <Button
                onClick={() => {
                  if (!dressType.trim()) return;
                  addDressType(dressType.trim());
                  setDressType("");
                }}
              >
                Add
              </Button>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Pricing rules</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="space-y-1.5">
              <Label>Commission (%)</Label>
              <Input
                type="number"
                value={settings.commissionPercent}
                onChange={(e) =>
                  updateSettings({
                    commissionPercent: Number(e.target.value) || 0,
                  })
                }
              />
            </div>
            <div className="space-y-1.5">
              <Label>Default deposit (%)</Label>
              <Input
                type="number"
                value={settings.defaultDepositPercent}
                onChange={(e) =>
                  updateSettings({
                    defaultDepositPercent: Number(e.target.value) || 0,
                  })
                }
              />
            </div>
            <div className="space-y-1.5">
              <Label>Currency</Label>
              <Input
                value={settings.currency}
                onChange={(e) => updateSettings({ currency: e.target.value })}
              />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-lg">Notification settings</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="space-y-1.5">
              <Label>Support email</Label>
              <Input
                value={settings.supportEmail}
                onChange={(e) =>
                  updateSettings({ supportEmail: e.target.value })
                }
              />
            </div>
            {(
              [
                ["notifyNewUsers", "Notify on new users"],
                ["notifyNewStores", "Notify on new stores"],
                ["notifyPendingDresses", "Notify on pending dresses"],
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
              Save settings
            </Button>
            {saved ? (
              <p className="text-xs text-success">Settings saved locally</p>
            ) : null}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
