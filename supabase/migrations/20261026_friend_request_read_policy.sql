-- NOX STUDY: allow each signed-in user to read only friend requests involving their own account.
-- Safe to rerun. This fixes: permission denied for table nox_friend_requests.
alter table public.nox_friend_requests enable row level security;

drop policy if exists "Users can read their own friend requests" on public.nox_friend_requests;
create policy "Users can read their own friend requests"
on public.nox_friend_requests
for select
to authenticated
using (auth.uid() = sender_id or auth.uid() = receiver_id);

grant select on public.nox_friend_requests to authenticated;
