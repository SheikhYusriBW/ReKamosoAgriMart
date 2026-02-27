# CURSOR PROMPT 1 — Initialize Monorepo Skeleton

> Paste everything below this line into Cursor.

---

## Context

Read the `ARCHITECTURE.md` file in the project root and all files in the `docs/` folder before doing anything. These contain the complete project specification.

I am building **ReKamoso AgriMart** — an agricultural marketplace platform. The full architecture is documented in those files. Do not deviate from what's specified.

## Task

Initialize the monorepo skeleton. **Structure only — no screens, no UI, no business logic yet.** Just the foundation that everything will be built on top of.

### Step 1: Root Workspace Setup

Create the root `package.json` with npm workspaces pointing to `apps/*` and `packages/*`. Create `tsconfig.base.json` with strict TypeScript settings that all sub-projects will extend. Update `.gitignore` for Node, Expo, Next.js, Supabase, and environment files.

### Step 2: Expo Mobile App (`apps/mobile/`)

Initialize an Expo app with:
- Expo Router (file-based routing) with the `(auth)`, `(farmer)`, and `(store)` route groups as empty folders with `_layout.tsx` placeholder files
- TypeScript
- Expo SDK 52 (or latest stable)
- The following dependencies: `@supabase/supabase-js`, `expo-router`, `expo-secure-store`, `expo-notifications`, `expo-image-picker`, `expo-location`, `@react-native-community/netinfo`, `react-native-mmkv`
- Create the folder structure from `docs/PROJECT_STRUCTURE.md` Section 2 — all folders for `components/`, `hooks/`, `services/`, `providers/`, `theme/`, `utils/`, `assets/` with empty `.gitkeep` files where needed
- Create `app.json` / `app.config.js` configured for the project name "ReKamoso AgriMart"
- Create `.env.example` with the required Supabase environment variables (see `ARCHITECTURE.md`)
- Do NOT create any actual screen content yet — just the routing skeleton and folder structure

### Step 3: Next.js Admin Panel (`apps/admin/`)

Initialize a Next.js app (App Router) with:
- TypeScript
- Tailwind CSS
- The following dependencies: `@supabase/supabase-js`, `@supabase/ssr`
- Create the folder structure from `docs/PROJECT_STRUCTURE.md` Section 3 — route folders for `/farmers`, `/stores`, `/catalogue`, `/transactions`, `/settings`, `/analytics`, `/login` with empty `page.tsx` placeholder files
- Create `components/`, `hooks/`, `services/` folders
- Create `.env.example` with the required environment variables
- Do NOT create any actual page content yet — just the routing skeleton and folder structure

### Step 4: Shared Package (`packages/shared/`)

Create the package with:
- `package.json` with name `@rekamoso/shared`
- `tsconfig.json` extending the base config
- Empty folder structure: `types/`, `constants/`, `utils/`
- Create `index.ts` that will re-export everything

### Step 5: Supabase Package (`packages/supabase/`)

Create the package with:
- `package.json` with name `@rekamoso/supabase`, depending on `@supabase/supabase-js`
- `tsconfig.json` extending the base config
- `client.ts` — Supabase client initialization using environment variables (see ARCHITECTURE.md for the pattern)
- Empty folder structure: `types/`, `queries/`, `realtime/`, `storage/`
- Create `index.ts` that exports the client

### Step 6: Supabase Project Config (`supabase/`)

Initialize Supabase locally:
- Create `supabase/config.toml` (or note that `supabase init` should be run manually)
- Create empty `supabase/migrations/` folder
- Create empty `supabase/seed.sql`
- Create empty `supabase/functions/` folder
- Create `.env.example` for Edge Function secrets

### Step 7: Root Scripts

Add these scripts to the root `package.json`:
```json
{
  "scripts": {
    "mobile": "cd apps/mobile && npx expo start",
    "mobile:ios": "cd apps/mobile && npx expo start --ios",
    "mobile:android": "cd apps/mobile && npx expo start --android",
    "mobile:web": "cd apps/mobile && npx expo start --web",
    "admin": "cd apps/admin && npm run dev",
    "db:generate-types": "supabase gen types typescript --project-id $SUPABASE_PROJECT_ID > packages/supabase/types/database.types.ts",
    "db:migrate": "supabase db push",
    "db:seed": "supabase db reset",
    "db:studio": "supabase studio"
  }
}
```

## Requirements

- Use TypeScript everywhere — no JavaScript files
- All `tsconfig.json` files in sub-projects should extend `../../tsconfig.base.json`
- Placeholder files should have minimal valid content (e.g., layout files should export a basic component, page files should export a basic component)
- Do not install dependencies that aren't listed — stick to what's specified
- Keep placeholder content minimal — just enough that the app compiles and runs without errors
- The Expo app should be able to start with `npx expo start` after setup
- The Next.js app should be able to start with `npm run dev` after setup

## Do NOT

- Do not create any actual UI screens or components
- Do not write any business logic
- Do not create database migrations yet
- Do not set up authentication flows yet
- Do not add any styling or theming beyond what's needed to compile

## Expected Result

After this task, I should be able to:
1. Run `npm install` at the root
2. Run `npm run mobile` and see a blank Expo app with routing skeleton
3. Run `npm run admin` and see a blank Next.js app with routing skeleton
4. See the complete folder structure from `docs/PROJECT_STRUCTURE.md` ready to be filled in
