-- LTB STOK V2 - SUPABASE AUTH + RLS GÜVENLİK GEÇİŞİ
-- UYARI: Önce README_GUVENLIK_KURULUM.md dosyasındaki sırayı okuyun.

begin;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  kullanici_kodu text not null unique,
  rol text not null check (rol in ('admin', 'mudur', 'personel')),
  magaza text not null,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create or replace function public.current_profile_role()
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select p.rol
  from public.profiles p
  where p.id = (select auth.uid())
$$;

create or replace function public.current_profile_store()
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select p.magaza
  from public.profiles p
  where p.id = (select auth.uid())
$$;

revoke all on function public.current_profile_role() from public;
revoke all on function public.current_profile_store() from public;
grant execute on function public.current_profile_role() to authenticated;
grant execute on function public.current_profile_store() to authenticated;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
on public.profiles
for select
to authenticated
using ((select auth.uid()) = id);

-- Mevcut stok tablosu geçiş/test kaynağıdır.
-- Nebim bağlantısından sonra Flutter doğrudan bu tabloyu kullanmayacaktır.
alter table public.stoklar enable row level security;
drop policy if exists "stoklar_authenticated_read" on public.stoklar;
create policy "stoklar_authenticated_read"
on public.stoklar
for select
to authenticated
using (true);

-- Mağaza listesi sadece giriş yapmış kullanıcılar tarafından okunabilir.
alter table public."mağazalar" enable row level security;
drop policy if exists "magazalar_authenticated_read" on public."mağazalar";
create policy "magazalar_authenticated_read"
on public."mağazalar"
for select
to authenticated
using (true);

-- Raflar okunabilir; değişiklik yalnızca admin veya kendi mağazasının müdürü tarafından yapılabilir.
alter table public.raflar enable row level security;

drop policy if exists "raflar_authenticated_read" on public.raflar;
create policy "raflar_authenticated_read"
on public.raflar
for select
to authenticated
using (true);

drop policy if exists "raflar_manager_insert" on public.raflar;
create policy "raflar_manager_insert"
on public.raflar
for insert
to authenticated
with check (
  (select public.current_profile_role()) = 'admin'
  or (
    (select public.current_profile_role()) = 'mudur'
    and magaza_adi = (select public.current_profile_store())
  )
);

drop policy if exists "raflar_manager_update" on public.raflar;
create policy "raflar_manager_update"
on public.raflar
for update
to authenticated
using (
  (select public.current_profile_role()) = 'admin'
  or (
    (select public.current_profile_role()) = 'mudur'
    and magaza_adi = (select public.current_profile_store())
  )
)
with check (
  (select public.current_profile_role()) = 'admin'
  or (
    (select public.current_profile_role()) = 'mudur'
    and magaza_adi = (select public.current_profile_store())
  )
);

drop policy if exists "raflar_manager_delete" on public.raflar;
create policy "raflar_manager_delete"
on public.raflar
for delete
to authenticated
using (
  (select public.current_profile_role()) = 'admin'
  or (
    (select public.current_profile_role()) = 'mudur'
    and magaza_adi = (select public.current_profile_store())
  )
);

-- Eski düz şifreli users tablosunu istemciden tamamen kapat.
alter table public.users enable row level security;
revoke all on table public.users from anon, authenticated;

-- Auth kullanıcısı oluşturulunca eski users kaydındaki rol/mağaza bilgisini profile aktar.
create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_code text;
begin
  v_code := split_part(lower(new.email), '@', 1);

  insert into public.profiles (id, kullanici_kodu, rol, magaza)
  select
    new.id,
    u.kullanici_kodu,
    u.rol,
    u."mağaza"
  from public.users u
  where lower(u.kullanici_kodu) = v_code
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created_ltb_profile on auth.users;
create trigger on_auth_user_created_ltb_profile
after insert on auth.users
for each row execute procedure public.handle_new_auth_user();

-- Auth kullanıcıları trigger kurulmadan önce oluşturulduysa profilleri eşleştir.
insert into public.profiles (id, kullanici_kodu, rol, magaza)
select
  au.id,
  u.kullanici_kodu,
  u.rol,
  u."mağaza"
from auth.users au
join public.users u
  on lower(au.email) = lower(u.kullanici_kodu || '@ltbstok.local')
on conflict (id) do nothing;

commit;
