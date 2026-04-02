with subs as (
    select * from {{ ref('stg_subscriptions') }}
),
dim_companies as (
    select * from {{ ref('dim_companies') }}
),
dim_plans as (
    select * from {{ ref('dim_plans') }}
),
dim_dates as (
    select * from {{ ref('dim_dates') }}
),
fact as (
    select
        dc.company_key,
        dp.plan_key,
        coalesce(dd_start.date_key,  -1)            as start_date_key,
        coalesce(dd_end.date_key,    -1)            as end_date_key,
        coalesce(dd_cohort.date_key, -1)            as cohort_date_key,
        s.subscription_id,
        s.company_id,
        s.plan,
        s.mrr,
        s.status,
        s.is_churned,
        s.start_date,
        s.end_date,
        date_trunc(s.start_date, MONTH)             as cohort_month,
        format_date('%Y-%m', s.start_date)          as cohort_label,
        case when s.status = 'Active' then s.mrr else 0 end as active_mrr,
        case when s.status = 'Active' then s.mrr * 12 else 0 end as arr,
        case when s.is_churned then s.mrr else 0 end as churned_mrr,
        case
            when s.end_date is not null
            then date_diff(s.end_date, s.start_date, DAY)
            else date_diff(date '2024-12-31', s.start_date, DAY)
        end                                         as days_active,
        case
            when s.end_date is not null
            then round(date_diff(s.end_date, s.start_date, DAY) / 30.0, 1)
            else round(date_diff(date '2024-12-31', s.start_date, DAY) / 30.0, 1)
        end                                         as months_active,
        s.mrr * case
            when s.end_date is not null
            then round(date_diff(s.end_date, s.start_date, DAY) / 30.0, 1)
            else round(date_diff(date '2024-12-31', s.start_date, DAY) / 30.0, 1)
        end                                         as ltv
    from subs s
    left join dim_companies dc    on s.company_id = dc.company_id
    left join dim_plans dp        on s.plan       = dp.plan_name
    left join dim_dates dd_start  on cast(format_date('%Y%m%d', s.start_date) as int64) = dd_start.date_key
    left join dim_dates dd_end    on cast(format_date('%Y%m%d', s.end_date)   as int64) = dd_end.date_key
    left join dim_dates dd_cohort on cast(format_date('%Y%m%d', date_trunc(s.start_date, MONTH)) as int64) = dd_cohort.date_key
)
select * from fact