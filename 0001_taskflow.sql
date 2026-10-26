-- TaskFlow initial schema. Run with `supabase db push` or paste into Supabase SQL Editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  role text not null default 'Pelajar',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  role text not null default 'Pelajar',
  wake_time time not null default '05:30',
  sleep_time time not null default '22:00',
  productive_start time not null default '16:00',
  productive_end time not null default '21:30',
  onboarding_complete boolean not null default false,
  notification_preferences jsonb not null default '{"browser":false,"deadline":true,"session":true}'::jsonb,
  timezone text not null default 'Asia/Jakarta',
  updated_at timestamptz not null default now()
);

create table if not exists public.user_schedules (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  day_of_week smallint not null check (day_of_week between 0 and 6),
  title text not null,
  start_time time not null,
  end_time time not null,
  is_fixed boolean not null default false,
  category text not null default 'Pribadi',
  created_at timestamptz not null default now(),
  check (start_time < end_time)
);
create index if not exists user_schedules_user_day_idx on public.user_schedules(user_id, day_of_week, start_time);

create table if not exists public.tasks (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text not null default '',
  category text not null default 'Umum',
  due_date date not null,
  due_time time not null default '23:00',
  duration_minutes integer not null default 30 check (duration_minutes > 0 and duration_minutes <= 1440),
  difficulty smallint not null default 3 check (difficulty between 1 and 5),
  importance smallint not null default 3 check (importance between 1 and 5),
  impact smallint not null default 3 check (impact between 1 and 5),
  status text not null default 'Belum dimulai' check (status in ('Belum dimulai','Sedang dikerjakan','Ditunda','Selesai')),
  priority text not null default 'Sedang' check (priority in ('Kritis','Tinggi','Sedang','Rendah')),
  scheduled_time time,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists tasks_user_due_idx on public.tasks(user_id, due_date, due_time);
create index if not exists tasks_user_status_idx on public.tasks(user_id, status);

create table if not exists public.task_subtasks (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  task_id text not null references public.tasks(id) on delete cascade,
  title text not null,
  is_complete boolean not null default false,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.task_sessions (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  task_id text not null references public.tasks(id) on delete cascade,
  session_date date not null,
  start_time time not null,
  end_time time not null,
  status text not null default 'planned' check (status in ('planned','in_progress','completed','skipped')),
  actual_minutes integer,
  created_at timestamptz not null default now(),
  check (start_time < end_time)
);
create index if not exists task_sessions_user_date_idx on public.task_sessions(user_id, session_date, start_time);

create table if not exists public.reminders (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  task_id text references public.tasks(id) on delete cascade,
  kind text not null check (kind in ('deadline','session','overdue','routine')),
  scheduled_at timestamptz not null,
  status text not null default 'pending' check (status in ('pending','processing','sent','failed','cancelled')),
  message text not null,
  sent_at timestamptz,
  last_error text,
  created_at timestamptz not null default now()
);
create index if not exists reminders_due_idx on public.reminders(status, scheduled_at) where status = 'pending';

create table if not exists public.notifications (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  reminder_id text references public.reminders(id) on delete set null,
  title text not null,
  body text not null,
  read_at timestamptz,
  created_at timestamptz not null default now()
);
create index if not exists notifications_user_created_idx on public.notifications(user_id, created_at desc);

create table if not exists public.onboarding_progress (
  user_id uuid primary key references auth.users(id) on delete cascade,
  current_step smallint not null default 0 check (current_step between 0 and 3),
  status text not null default 'NOT_STARTED' check (status in ('NOT_STARTED','IN_PROGRESS','READY')),
  updated_at timestamptz not null default now()
);

create table if not exists public.push_subscriptions (
  id text primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  endpoint text not null,
  p256dh text not null,
  auth_key text not null,
  user_agent text,
  created_at timestamptz not null default now(),
  unique(user_id, endpoint)
);

-- RLS is enabled on every user-owned table. Policies restrict all client access to the owner.
do $$
declare tbl text; owner_expr text;
begin
  foreach tbl in array array['profiles','user_settings','user_schedules','tasks','task_subtasks','task_sessions','reminders','notifications','onboarding_progress','push_subscriptions'] loop
    owner_expr := case when tbl = 'profiles' then 'id' else 'user_id' end;
    execute format('alter table public.%I enable row level security', tbl);
    execute format('drop policy if exists %I on public.%I', tbl || '_owner_select', tbl);
    execute format('create policy %I on public.%I for select to authenticated using (auth.uid() = %I)', tbl || '_owner_select', tbl, owner_expr);
    execute format('drop policy if exists %I on public.%I', tbl || '_owner_insert', tbl);
    execute format('create policy %I on public.%I for insert to authenticated with check (auth.uid() = %I)', tbl || '_owner_insert', tbl, owner_expr);
    execute format('drop policy if exists %I on public.%I', tbl || '_owner_update', tbl);
    execute format('create policy %I on public.%I for update to authenticated using (auth.uid() = %I) with check (auth.uid() = %I)', tbl || '_owner_update', tbl, owner_expr, owner_expr);
    execute format('drop policy if exists %I on public.%I', tbl || '_owner_delete', tbl);
    execute format('create policy %I on public.%I for delete to authenticated using (auth.uid() = %I)', tbl || '_owner_delete', tbl, owner_expr);
  end loop;
end $$;

-- The subtasks table uses user_id and task_id. RLS ownership check is reinforced by the foreign key,
-- and the app must always set user_id from the authenticated session, never from client-supplied identity.

-- Ensure a subtask can only reference a task owned by the same authenticated user.
drop policy if exists task_subtasks_owner_select on public.task_subtasks;
create policy task_subtasks_owner_select on public.task_subtasks for select to authenticated
  using (auth.uid() = user_id and exists (select 1 from public.tasks t where t.id = task_id and t.user_id = auth.uid()));
drop policy if exists task_subtasks_owner_insert on public.task_subtasks;
create policy task_subtasks_owner_insert on public.task_subtasks for insert to authenticated
  with check (auth.uid() = user_id and exists (select 1 from public.tasks t where t.id = task_id and t.user_id = auth.uid()));
drop policy if exists task_subtasks_owner_update on public.task_subtasks;
create policy task_subtasks_owner_update on public.task_subtasks for update to authenticated
  using (auth.uid() = user_id and exists (select 1 from public.tasks t where t.id = task_id and t.user_id = auth.uid()))
  with check (auth.uid() = user_id and exists (select 1 from public.tasks t where t.id = task_id and t.user_id = auth.uid()));
drop policy if exists task_subtasks_owner_delete on public.task_subtasks;
create policy task_subtasks_owner_delete on public.task_subtasks for delete to authenticated
  using (auth.uid() = user_id and exists (select 1 from public.tasks t where t.id = task_id and t.user_id = auth.uid()));
