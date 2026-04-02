with subs as (
    select * from {{ ref('stg_subscriptions') }}
),
companies as (
    select * from {{ ref('stg_companies') }}
),
mrr as (
    select
        s.subscription_id,
        s.company_id,
        c.company_name,
        c.segment,
        c.industry,
        s.plan,
        s.mrr,
        s.status,
        s.start_date,
        s.end_date,
        date_trunc(s.start_date, MONTH)             as cohort_month,
        case
            when s.status = 'Active' then s.mrr
            else 0
        end                                         as active_mrr,
        case
            when s.status = 'Active' then s.mrr * 12
            else 0
        end                                         as arr
    from subs s
    left join companies c on s.company_id = c.company_id
)
select * from mrr