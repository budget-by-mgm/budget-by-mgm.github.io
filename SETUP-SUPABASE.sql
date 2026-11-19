-- À lancer UNE fois dans Supabase : SQL Editor > New query > coller > Run.
-- Crée la table où chaque personne range son budget. Chacun ne voit et ne modifie que ses propres lignes.
create table if not exists public.budget_docs (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  key text not null,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  primary key (user_id, key)
);
alter table public.budget_docs enable row level security;
drop policy if exists "budget_lire" on public.budget_docs;
drop policy if exists "budget_creer" on public.budget_docs;
drop policy if exists "budget_modifier" on public.budget_docs;
drop policy if exists "budget_supprimer" on public.budget_docs;
create policy "budget_lire" on public.budget_docs for select to authenticated using (auth.uid() = user_id);
create policy "budget_creer" on public.budget_docs for insert to authenticated with check (auth.uid() = user_id);
create policy "budget_modifier" on public.budget_docs for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "budget_supprimer" on public.budget_docs for delete to authenticated using (auth.uid() = user_id);
revoke all on public.budget_docs from anon;
grant select, insert, update, delete on public.budget_docs to authenticated;
