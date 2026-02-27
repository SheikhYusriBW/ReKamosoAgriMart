# ReKamoso AgriMart

Agricultural marketplace platform connecting farmers to retail storefronts.

## Project Structure

This is a monorepo containing:

- `apps/mobile/` - Expo mobile app (Farmer + Store roles)
- `apps/admin/` - Next.js admin panel
- `packages/shared/` - Shared TypeScript types, constants, utilities
- `packages/supabase/` - Supabase client and queries
- `supabase/` - Database migrations, seed data, Edge Functions

## Setup

### Prerequisites

- Node.js 18+ and npm
- Expo CLI (installed globally or via npx)
- Supabase CLI (for database management)

### Installation

1. Install dependencies:
```bash
npm install
```

2. Set up environment variables:
   - Copy `apps/mobile/.env.example` to `apps/mobile/.env` and fill in Supabase credentials
   - Copy `apps/admin/.env.example` to `apps/admin/.env.local` and fill in Supabase credentials
   - Copy `supabase/.env.example` to `supabase/.env` and fill in Edge Function secrets

3. Initialize Supabase (if using local development):
```bash
supabase init
supabase start
```

4. Run migrations and seed data:
```bash
npm run db:migrate
npm run db:seed
```

5. Generate TypeScript types from database:
```bash
npm run db:generate-types
```

## Development

### Mobile App

```bash
npm run mobile          # Start Expo dev server
npm run mobile:ios      # Start on iOS simulator
npm run mobile:android  # Start on Android emulator
npm run mobile:web      # Start web version
```

### Admin Panel

```bash
npm run admin           # Start Next.js dev server (http://localhost:3000)
```

## Database Management

```bash
npm run db:migrate      # Push migrations to database
npm run db:seed         # Reset database and run seed data
npm run db:studio       # Open Supabase Studio
npm run db:generate-types  # Generate TypeScript types from database schema
```

## Documentation

- `ARCHITECTURE.md` - Technical architecture reference
- `docs/PROJECT_BRIEF.md` - Full project specification
- `docs/DATABASE_SCHEMA.md` - Complete database schema
- `docs/PROJECT_STRUCTURE.md` - Folder structure and conventions
- `docs/SCREEN_MAP.md` - Screen-by-screen breakdown

## License

Private - ReKamoso AgriMart
