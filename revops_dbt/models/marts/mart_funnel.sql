with deals as (
    select * from main.stg_deals
),

companies as (
    select * from main.stg_companies
),

activities as (
    select * from main.stg_activities
),

deal_activities as (
    select
        deal_id,
        count(*)                                        as total_activities,
        count(case when activity_type = 'Call'     then 1 end) as total_calls,
        count(case when activity_type = 'Email'    then 1 end) as total_emails,
        count(case when activity_type = 'Meeting'  then 1 end) as total_meetings,
        count(case when activity_type = 'Demo'     then 1 end) as total_demos,
        count(case when outcome = 'Positive'       then 1 end) as positive_outcomes,
        count(case when outcome = 'Negative'       then 1 end) as negative_outcomes
    from activities
    group by deal_id
),

stage_order as (
    select 1 as order_num, 'Prospecting'  as stage union all
    select 2,              'Qualified'             union all
    select 3,              'Proposal'              union all
    select 4,              'Negotiation'           union all
    select 5,              'Closed Won'            union all
    select 6,              'Closed Lost'
),

funnel as (
    select
        d.deal_id,
        d.company_id,
        c.company_name,
        c.segment,
        c.industry,
        c.employees,
        d.plan,
        d.stage,
        so.order_num                                    as stage_order,
        d.amount,
        d.created_at,
        d.closed_at,
        d.is_closed,
        d.is_won,
        case
            when d.is_won then d.amount
            else 0
        end                                             as won_amount,
        case
            when d.closed_at is not null
            then cast(d.closed_at - d.created_at as integer)
            else null
        end                                             as days_to_close,
        case
            when cast(d.closed_at - d.created_at as integer) <= 30  then 'Ate 30 dias'
            when cast(d.closed_at - d.created_at as integer) <= 60  then '31 a 60 dias'
            when cast(d.closed_at - d.created_at as integer) <= 90  then '61 a 90 dias'
            when cast(d.closed_at - d.created_at as integer) > 90   then 'Mais de 90 dias'
            else 'Em andamento'
        end                                             as sales_cycle_bucket,
        'Q' || quarter(d.created_at) || ' ' ||
        year(d.created_at)                              as deal_quarter,
        strftime(d.created_at, '%Y-%m')                as deal_month,
        year(d.created_at)                              as deal_year,
        case
            when d.closed_at is not null
            then 'Q' || quarter(d.closed_at) || ' ' || year(d.closed_at)
            else null
        end                                             as close_quarter,
        case
            when not d.is_closed then true
            else false
        end                                             as is_open,
        coalesce(da.total_activities, 0)                as total_activities,
        coalesce(da.total_calls, 0)                     as total_calls,
        coalesce(da.total_emails, 0)                    as total_emails,
        coalesce(da.total_meetings, 0)                  as total_meetings,
        coalesce(da.total_demos, 0)                     as total_demos,
        coalesce(da.positive_outcomes, 0)               as positive_outcomes,
        coalesce(da.negative_outcomes, 0)               as negative_outcomes,
        case
            when coalesce(da.total_activities, 0) > 0
            then round(
                coalesce(da.positive_outcomes, 0) * 100.0 / da.total_activities,
                1
            )
            else 0
        end                                             as positive_outcome_pct
    from deals d
    left join companies c        on d.company_id = c.company_id
    left join stage_order so     on d.stage = so.stage
    left join deal_activities da on d.deal_id = da.deal_id
)

select * from funnel
