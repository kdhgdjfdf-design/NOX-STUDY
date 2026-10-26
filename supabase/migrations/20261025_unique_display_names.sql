-- NOX STUDY: display names must be unique and immutable once set.
-- Run this file in the Supabase SQL Editor.
-- If the unique index fails, resolve existing duplicate names first.

create unique index if not exists nox_profiles_display_name_unique
on public.nox_profiles (lower(trim(display_name)))
where display_name is not null and trim(display_name) <> '';

create or replace function public.nox_prevent_display_name_change()
returns trigger
language plpgsql
as $$
begin
  if old.display_name is not null
     and trim(old.display_name) <> ''
     and lower(trim(coalesce(new.display_name, ''))) <> lower(trim(old.display_name)) then
    raise exception 'Display name cannot be changed after it is set';
  end if;
  return new;
end;
$$;

drop trigger if exists nox_display_name_immutable on public.nox_profiles;
create trigger nox_display_name_immutable
before update of display_name on public.nox_profiles
for each row execute function public.nox_prevent_display_name_change();
