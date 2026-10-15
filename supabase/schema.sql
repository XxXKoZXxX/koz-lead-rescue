-- KoZ Lead Rescue MVP schema
-- Apply this in the dedicated KoZ Lead Rescue Supabase project.
-- Every exposed table has RLS enabled. Never put a service-role key in the browser.

create extension if not exists pgcrypto;

create table if not exists public.businesses (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null unique references auth.users(id) on delete cascade,
  business_name text not null default 'My Business' check (char_length(business_name) between 1 and 120),
  service_area text not null default '',
  timezone text not null default 'America/New_York',
  owner_email text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  name text not null check (char_length(name) between 1 and 120),
  email text not null default '',
  phone text not null default '',
  zip text not null default '',
  service text not null default 'General inquiry',
  urgency text not null default 'Not specified',
  preferred text not null default '',
  details text not null default '',
  status text not null default 'new' check (status in ('new', 'reviewing', 'follow_up', 'closed')),
  note text not null default '',
  consent_to_contact boolean not null default false,
  source text not null default 'manual',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists leads_business_created_idx
  on public.leads (business_id, created_at desc);
create index if not exists leads_business_status_idx
  on public.leads (business_id, status);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists businesses_set_updated_at on public.businesses;
create trigger businesses_set_updated_at
before update on public.businesses
for each row execute function public.set_updated_at();

drop trigger if exists leads_set_updated_at on public.leads;
create trigger leads_set_updated_at
before update on public.leads
for each row execute function public.set_updated_at();

alter table public.businesses enable row level security;
alter table public.leads enable row level security;

drop policy if exists "Owners can read their business" on public.businesses;
create policy "Owners can read their business"
on public.businesses for select to authenticated
using ((select auth.uid()) = owner_id);

drop policy if exists "Owners can create their business" on public.businesses;
create policy "Owners can create their business"
on public.businesses for insert to authenticated
with check ((select auth.uid()) = owner_id);

drop policy if exists "Owners can update their business" on public.businesses;
create policy "Owners can update their business"
on public.businesses for update to authenticated
using ((select auth.uid()) = owner_id)
with check ((select auth.uid()) = owner_id);

drop policy if exists "Owners can delete their business" on public.businesses;
create policy "Owners can delete their business"
on public.businesses for delete to authenticated
using ((select auth.uid()) = owner_id);

drop policy if exists "Owners can read their leads" on public.leads;
create policy "Owners can read their leads"
on public.leads for select to authenticated
using (exists (
  select 1 from public.businesses b
  where b.id = business_id and b.owner_id = (select auth.uid())
));

drop policy if exists "Owners can create their leads" on public.leads;
create policy "Owners can create their leads"
on public.leads for insert to authenticated
with check (exists (
  select 1 from public.businesses b
  where b.id = business_id and b.owner_id = (select auth.uid())
));

drop policy if exists "Owners can update their leads" on public.leads;
create policy "Owners can update their leads"
on public.leads for update to authenticated
using (exists (
  select 1 from public.businesses b
  where b.id = business_id and b.owner_id = (select auth.uid())
))
with check (exists (
  select 1 from public.businesses b
  where b.id = business_id and b.owner_id = (select auth.uid())
));

drop policy if exists "Owners can delete their leads" on public.leads;
create policy "Owners can delete their leads"
on public.leads for delete to authenticated
using (exists (
  select 1 from public.businesses b
  where b.id = business_id and b.owner_id = (select auth.uid())
));

grant select, insert, update, delete on public.businesses to authenticated;
grant select, insert, update, delete on public.leads to authenticated;
