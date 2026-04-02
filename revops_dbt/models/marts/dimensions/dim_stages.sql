select
    stage_order                                     as stage_key,
    stage                                           as stage_name,
    stage_order,
    case when stage in ('Closed Won', 'Closed Lost') then true else false end as is_closed,
    case when stage = 'Closed Won'  then true else false end as is_won,
    case when stage = 'Closed Lost' then true else false end as is_lost
from (
    select 1 as stage_order, 'Prospecting'  as stage union all
    select 2,                'Qualified'             union all
    select 3,                'Proposal'              union all
    select 4,                'Negotiation'           union all
    select 5,                'Closed Won'            union all
    select 6,                'Closed Lost'
)