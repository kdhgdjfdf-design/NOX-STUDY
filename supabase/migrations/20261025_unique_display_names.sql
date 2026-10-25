-- NOX STUDY: enforce unique display names at database level.
-- Run this in the Supabase SQL Editor after resolving any existing duplicate names.
create unique index if not exists nox_profiles_display_name_unique
on public.nox_profiles (lower(trim(display_name)))
where display_name is not null and trim(display_name) <> '';
