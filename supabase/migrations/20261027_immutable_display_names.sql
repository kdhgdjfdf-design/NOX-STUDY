-- NOX STUDY: make display names immutable after profile creation.
-- Run in Supabase SQL Editor. Existing profile names remain unchanged.
create or replace function public.nox_prevent_display_name_change()
returns trigger
language plpgsql
as $$
begin
  if lower(trim(coalesce(new.display_name, ''))) <> lower(trim(coalesce(old.display_name, ''))) then
    raise exception 'اسم العرض لا يمكن تغييره بعد إنشاء الحساب';
  end if;
  return new;
end;
$$;

drop trigger if exists nox_display_name_immutable on public.nox_profiles;
create trigger nox_display_name_immutable
before update of display_name on public.nox_profiles
for each row
execute function public.nox_prevent_display_name_change();
