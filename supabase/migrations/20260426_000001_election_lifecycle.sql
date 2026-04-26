-- Election lifecycle automation (create -> nomination -> voting -> completed).
--
-- This adds a single RPC `public.run_election_lifecycle()` that you can run from:
-- - a scheduled Supabase Edge Function (recommended), or
-- - a cron job outside Supabase, or
-- - manually for debugging.
--
-- Assumptions:
-- - `public.communities(id uuid primary key, created_at timestamptz)` exists.
-- - `public.community_members(community_id uuid, user_id uuid, role text, status text)` exists.
-- - The tables `public.elections`, `public.nominations`, `public.votes` already exist (as per your SQL).

create or replace function public.run_election_lifecycle()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_now timestamptz := now();
begin
  -- 1) Create a new election for any community that has NO active election
  --    and hasn't had an election in the last 4 months.
  insert into public.elections (
    community_id,
    status,
    nomination_end,
    voting_end,
    is_active,
    admin_assigned,
    voting_notified,
    result_notified
  )
  select
    c.id as community_id,
    'nomination'::text as status,
    v_now + interval '3 hours' as nomination_end,
    v_now + interval '6 hours' as voting_end,
    true as is_active,
    false as admin_assigned,
    false as voting_notified,
    false as result_notified
  from public.communities c
  left join lateral (
    select e.created_at
    from public.elections e
    where e.community_id = c.id
    order by e.created_at desc
    limit 1
  ) last_election on true
  where not exists (
    select 1
    from public.elections ae
    where ae.community_id = c.id and ae.is_active = true
  )
  and (
    last_election.created_at is null
    or last_election.created_at <= v_now - interval '4 months'
  );

  -- 2) Update active elections status based on timestamps.
  update public.elections e
  set status =
    case
      when v_now < e.nomination_end then 'nomination'
      when v_now < e.voting_end then 'voting'
      else 'completed'
    end
  where e.is_active = true;

  -- 3) Finalize elections that ended voting but haven't assigned admin.
  --    Winner = candidate_id with highest count(*) in votes for that election.
  with ended as (
    select e.id as election_id, e.community_id
    from public.elections e
    where e.is_active = true
      and e.admin_assigned = false
      and v_now >= e.voting_end
  ),
  winners as (
    select
      v.election_id,
      v.candidate_id as winner_id,
      count(*) as votes
    from public.votes v
    join ended on ended.election_id = v.election_id
    group by v.election_id, v.candidate_id
  ),
  ranked as (
    select
      w.*,
      row_number() over (partition by w.election_id order by w.votes desc, w.winner_id asc) as rn
    from winners w
  ),
  picked as (
    select election_id, winner_id
    from ranked
    where rn = 1
  )
  -- demote current admin
  update public.community_members cm
  set role = 'member'
  from ended
  where cm.community_id = ended.community_id
    and cm.role = 'admin';

  -- promote winner to admin (only if there was at least 1 vote)
  update public.community_members cm
  set role = 'admin'
  from ended
  join picked on picked.election_id = ended.election_id
  where cm.community_id = ended.community_id
    and cm.user_id = picked.winner_id;

  -- mark election completed and inactive
  update public.elections e
  set
    is_active = false,
    admin_assigned = true,
    status = 'completed'
  where e.id in (select election_id from ended)
    and v_now >= e.voting_end;
end;
$$;

revoke all on function public.run_election_lifecycle() from public;
grant execute on function public.run_election_lifecycle() to service_role;

