-- NOX STUDY account profiles: create a profile + personal friend code on every new auth signup.
-- Run this in Supabase SQL Editor. Resolve existing duplicate display names/codes first if index creation fails.
alter table public.nox_profiles
  add column if not exists user_id uuid references auth.users(id) on delete cascade,
  add column if not exists display_name text,
  add column if not exists friend_code text,
  add column if not exists created_at timestamptz not null default now();

create unique index if not exists nox_profiles_user_id_unique
  on public.nox_profiles (user_id);

create unique index if not exists nox_profiles_friend_code_unique
  on public.nox_profiles (friend_code)
  where friend_code is not null;

create unique index if not exists nox_profiles_display_name_unique
  on public.nox_profiles (lower(trim(display_name)))
  where display_name is not null and trim(display_name) <> '';

create or replace function public.nox_handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  chosen_name text;
  generated_code text;
begin
  chosen_name := nullif(trim(regexp_replace(coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1)), '\s+', ' ', 'g')), '');
  if chosen_name is null then
    chosen_name := 'NOX-' || upper(substr(md5(new.id::text), 1, 6));
  end if;

  -- The unique display-name index is the final guard against duplicates.
  generated_code := 'NOX-' || upper(substr(md5(new.id::text || clock_timestamp()::text || random()::text), 1, 6));

  insert into public.nox_profiles (user_id, display_name, friend_code)
  values (new.id, chosen_name, generated_code)
  on conflict (user_id) do update
    set display_name = coalesce(public.nox_profiles.display_name, excluded.display_name),
        friend_code = coalesce(public.nox_profiles.friend_code, excluded.friend_code);

  return new;
end;
$$;

drop trigger if exists nox_on_auth_user_created on auth.users;
create trigger nox_on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.nox_handle_new_user();
