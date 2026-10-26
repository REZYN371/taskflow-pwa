# TaskFlow PWA

TaskFlow is a mobile-first Indonesian productivity planner built with Next.js, TypeScript, Tailwind CSS, and optional Supabase authentication/database sync. It includes a required schedule onboarding flow, task CRUD, a deterministic priority score, free-slot recommendations, schedule management, calendar, reminders UI, productivity statistics, JSON export, and a PWA shell.

> **Important status note:** this repository is a runnable starter project. It is not automatically deployed, and production account sync/reminders require the setup steps below. Browser-local data is used when Supabase is not configured. Background Web Push is not claimed to be active by default.

## Deploy from Android

See [`ANDROID_DEPLOY_GUIDE.md`](./ANDROID_DEPLOY_GUIDE.md) for step-by-step instructions to upload the ZIP through GitHub, unpack it in Codespaces, configure Supabase, and deploy to Vercel from an Android phone.

## Requirements

- Node.js 20 LTS or newer
- npm
- A Supabase project for multi-device account sync
- A Vercel account for public hosting (optional for local development)

## Run locally

```bash
npm install
cp .env.example .env.local
npm run dev
```

Open `http://localhost:3000`. Without Supabase environment values, the UI runs in local demo mode. Tasks and schedules are saved in the current browser's local storage, so they do not sync across devices.

## Enable Supabase authentication and sync

1. Create a project at https://supabase.com/.
2. In Project Settings → API, copy the project URL and anon/public key into `.env.local` as `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY`.
3. Run the SQL migration in `supabase/migrations/0001_taskflow.sql` using Supabase SQL Editor, or use the Supabase CLI.
4. In Authentication → URL Configuration, add your local URL and deployed URL to allowed redirect URLs.
5. Restart the dev server after changing environment variables.
6. Register/log in through TaskFlow. The current app persists tasks, schedules, and onboarding preferences to Supabase for an authenticated user.

Never expose `SUPABASE_SERVICE_ROLE_KEY` in any `NEXT_PUBLIC_` variable or client-side code. RLS must remain enabled.

### Notes about the current sync adapter

- The app's client-side adapter uses the Supabase anon key and authenticated session.
- Existing local demo rows are not automatically migrated to the remote account. Add new tasks after signing in to persist them.
- This starter uses a small direct client adapter; for production, move mutations into server actions/route handlers, validate payloads with Zod, and add conflict-aware schedule synchronization.
- Before production, test the SQL migration in a fresh Supabase project. Review RLS policies and use server-side ownership checks for every privileged action.

## Deploy to Vercel

1. Push this folder to a private or public GitHub repository.
2. Import the repository in https://vercel.com/.
3. Add `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` in Vercel Project Settings → Environment Variables.
4. Deploy and add the resulting Vercel URL to Supabase Auth's allowed redirect URLs.
5. Test registration, login, task sync, schedule sync, mobile layout, and RLS from a second browser/device.

A custom domain is optional. Vercel can provide a public `*.vercel.app` URL. Deployment is only complete after Vercel reports success and the URL is tested.

## Reminder setup

- The notification page can request browser notification permission.
- A browser permission prompt is not the same as a scheduled reminder delivery.
- The Edge Function in `supabase/functions/send-reminders/index.ts` is a foundation that creates in-app notifications for due reminder rows. It intentionally does **not** claim to send Web Push.
- Deploy it with the Supabase CLI, configure `REMINDER_CRON_SECRET`, and invoke it from a trusted scheduler with the `x-cron-secret` header.
- To send actual Web Push, add a maintained Web Push implementation compatible with the runtime, configure VAPID keys as server secrets, implement subscription management and invalid-endpoint cleanup, and test on each target browser. Do not place private VAPID or service-role keys in frontend code.
- Reminder rows must be created by a trusted, validated backend flow. Do not let clients create arbitrary notifications for other users.

## PWA

The project includes `public/manifest.json`, `public/icon.svg`, and `public/sw.js`. HTTPS is required for service workers outside localhost. The service worker caches selected static assets and provides a navigation fallback; it is not a full offline database and does not cache authenticated user data.

## Build checks

```bash
npm run build
```

Before production, test onboarding enforcement, task validation, priority ranking, overlapping schedule detection, timezone behavior, RLS isolation, notification behavior, and responsive layouts on real Android and iOS devices.

## Feature status

- Implemented in UI: onboarding, task management, priority calculation, suggested free slots, calendar view, schedule management, statistics, JSON export, responsive navigation, theme toggle, notification permission request.
- Optional configured integration: Supabase Auth, task/schedule/settings persistence.
- Requires production configuration/testing: Vercel deployment, real background scheduling, actual Web Push delivery, production-grade server-side validation and mutation routes, cross-device conflict resolution.
