create extension if not exists pgcrypto;

create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  titulo text not null,
  data date not null,
  hora time,
  categoria text,
  prioridade text not null default 'medium' check (prioridade in ('low','medium','high')),
  status text not null default 'Pendente' check (status in ('Pendente','Em andamento','Aguardando retorno','Concluída','Cancelada')),
  paciente text,
  profissional text,
  responsavel text,
  telefone text,
  observacoes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists tasks_user_id_idx on public.tasks(user_id);
create index if not exists tasks_user_date_idx on public.tasks(user_id, data);

alter table public.tasks enable row level security;
grant select, insert, update, delete on public.tasks to authenticated;

drop policy if exists "tasks_select_own" on public.tasks;
drop policy if exists "tasks_insert_own" on public.tasks;
drop policy if exists "tasks_update_own" on public.tasks;
drop policy if exists "tasks_delete_own" on public.tasks;

create policy "tasks_select_own" on public.tasks for select to authenticated
using ((select auth.uid()) is not null and (select auth.uid()) = user_id);

create policy "tasks_insert_own" on public.tasks for insert to authenticated
with check ((select auth.uid()) is not null and (select auth.uid()) = user_id);

create policy "tasks_update_own" on public.tasks for update to authenticated
using ((select auth.uid()) is not null and (select auth.uid()) = user_id)
with check ((select auth.uid()) is not null and (select auth.uid()) = user_id);

create policy "tasks_delete_own" on public.tasks for delete to authenticated
using ((select auth.uid()) is not null and (select auth.uid()) = user_id);

do $$
begin
  alter publication supabase_realtime add table public.tasks;
exception when duplicate_object then null;
end $$;
