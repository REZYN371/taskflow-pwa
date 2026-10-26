# TaskFlow deployment checklist

- [ ] Create Supabase project.
- [ ] Run `supabase/migrations/0001_taskflow.sql` in a fresh project and inspect any SQL errors.
- [ ] Set `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` locally.
- [ ] Verify RLS by signing in with two separate accounts and attempting cross-account reads/writes.
- [ ] Add production auth callback URLs in Supabase.
- [ ] Push project to GitHub.
- [ ] Import repository in Vercel.
- [ ] Set environment variables in Vercel and deploy.
- [ ] Open the public URL on Android and iPhone.
- [ ] Test account creation, login, task sync, schedule sync, and reload behavior.
- [ ] Configure trusted scheduler and `REMINDER_CRON_SECRET` if using reminder worker.
- [ ] Implement and test actual Web Push before advertising push reminders as available.
- [ ] Review privacy notice, account deletion, backups, rate limits, and production security.
