# Diah Admin Web

Next.js administration dashboard for the Diah fashion rental platform.

Prototype only — all data is local (Zustand + seed). No backend.

## Stack

- Next.js (App Router) + TypeScript
- Tailwind CSS
- shadcn-style UI primitives
- Zustand
- TanStack Table
- Recharts
- React Hook Form + Zod

## Run

Requires Node.js 18+.

```bash
cd apps/admin-web
npm install
npm run dev
```

Open http://localhost:3000

### Demo login

- Email: `admin@diah.dz`
- Password: `admin123`

## Structure

```
src/
  app/           # Routes (dashboard, users, stores, …)
  components/    # UI, layout, tables
  lib/           # utils, constants, mock-data
  stores/        # Zustand stores (data layer)
  types/         # TypeScript models
```

Swap `stores/` mock logic for API clients later without rewriting pages.
