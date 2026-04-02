with deals as (
    select * from {{ ref('stg_deals') }}
),
companies as (
    select * from {{ ref('stg_companies') }}
),
dim_companies as (
    select * from {{ ref('dim_companies') }}
),
dim_plans as (
    select * from {{ ref('dim_plans') }}
),
dim_stages as (
    select * from {{ ref('dim_stages') }}
),
dim_dates as (
    select * from {{ ref('dim_dates') }}
),
fact as (
    select
        dc.company_key,
        dp.plan_key,
        ds.stage_key,
        coalesce(dd_created.date_key, -1)           as created_date_key,
        coalesce(dd_closed.date_key,  -1)           as closed_date_key,
        d.deal_id,
        d.amount,
        case when d.is_won then d.amount else 0 end as won_amount,
        case
            when d.closed_at is not null
            then date_diff(d.closed_at, d.created_at, DAY)
            else null
        end                                         as days_to_close,
        d.is_won,
        d.is_closed,
        case when not d.is_closed then true else false end as is_open,
        d.stage,
        d.plan,
        c.segment,
        c.industry
    from deals d
    left join companies c       on d.company_id  = c.company_id
    left join dim_companies dc  on d.company_id  = dc.company_id
    left join dim_plans dp      on d.plan        = dp.plan_name
    left join dim_stages ds     on d.stage       = ds.stage_name
    left join dim_dates dd_created on cast(format_date('%Y%m%d', d.created_at) as int64) = dd_created.date_key
    left join dim_dates dd_closed  on cast(format_date('%Y%m%d', d.closed_at)  as int64) = dd_closed.date_key
)
select * from fact