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

-- Boîte à idées « Points à améliorer » : chacun envoie et voit ses envois, seul l'admin voit et trie tout.
create table if not exists public.budget_feedback (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  email text,
  type text not null default 'idee',
  texte text not null check (char_length(texte) between 3 and 1000),
  statut text not null default 'nouveau',
  created_at timestamptz not null default now()
);
alter table public.budget_feedback enable row level security;
drop policy if exists "fb_envoyer" on public.budget_feedback;
drop policy if exists "fb_voir" on public.budget_feedback;
drop policy if exists "fb_trier" on public.budget_feedback;
drop policy if exists "fb_supprimer" on public.budget_feedback;
create policy "fb_envoyer" on public.budget_feedback for insert to authenticated with check (auth.uid() = user_id and statut = 'nouveau');
create policy "fb_voir" on public.budget_feedback for select to authenticated using (auth.uid() = user_id or lower(auth.jwt() ->> 'email') = 'gouissemmathys@gmail.com');
create policy "fb_trier" on public.budget_feedback for update to authenticated using (lower(auth.jwt() ->> 'email') = 'gouissemmathys@gmail.com');
create policy "fb_supprimer" on public.budget_feedback for delete to authenticated using (lower(auth.jwt() ->> 'email') = 'gouissemmathys@gmail.com');
revoke all on public.budget_feedback from anon;
grant select, insert, update, delete on public.budget_feedback to authenticated;
