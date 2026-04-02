with subs as (
    select * from {{ ref('stg_subscriptions') }}
),
companies as (
    select * from {{ ref('stg_companies') }}
),
churn as (
    select
        s.subscription_id,
        s.company_id,
        c.company_name,
        c.segment,
        c.industry,
        s.plan,
        s.mrr,
        s.status,
        s.is_churned,
        s.start_date,
        s.end_date,
        case
            when s.is_churned then s.mrr
            else 0
        end                                         as churned_mrr,
        case
            when s.end_date is not null
            then date_diff(s.end_date, s.start_date, DAY)
            else null
        end                                         as days_active
    from subs s
    left join companies c on s.company_id = c.company_id
)
select * from churn