# Diah

Luxury dress rental marketplace for Algeria — Flutter mobile prototype.

## Features

- Browse, search, and filter luxury dresses
- Favorites, booking flow with calendar + mock payment
- Customer / Individual Owner / Store Owner roles
- Owner & Store dashboards with live stats
- Arabic (RTL) first, French second
- In-memory fake backend (Riverpod) — no Firebase / API / local DB

## Demo accounts

| Role | Phone | Password |
|------|-------|----------|
| Customer | `0555123456` | `123456` |
| Individual owner | `0666789012` | `123456` |
| Store owner | `0777111222` | `123456` |

OTP mock code: `1234`

## Run

```bash
flutter pub get
flutter run
```

## Architecture

Feature-first Clean Architecture with repository interfaces.
Swap `Fake*Repository` implementations for real API clients later without touching UI.
