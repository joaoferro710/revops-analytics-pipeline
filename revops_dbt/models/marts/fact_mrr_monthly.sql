with subs as (
    select * from {{ ref('stg_subscriptions') }}
),
plan_changes as (
    select * from {{ ref('stg_plan_changes') }}
),
dim_companies as (
    select * from {{ ref('dim_companies') }}
),
dim_plans as (
    select * from {{ ref('dim_plans') }}
),
new_mrr as (
    select
        date_trunc(s.start_date, MONTH)             as month_start,
        s.company_id,
        s.plan,
        s.mrr                                       as mrr_amount,
        'New'                                       as mrr_type
    from subs s
),
churned_mrr as (
    select
        date_trunc(s.end_date, MONTH)               as month_start,
        s.company_id,
        s.plan,
        -s.mrr                                      as mrr_amount,
        'Churned'                                   as mrr_type
    from subs s
    where s.is_churned = true
      and s.end_date is not null
),
expansion_mrr as (
    select
        date_trunc(pc.change_date, MONTH)           as month_start,
        pc.company_id,
        pc.to_plan                                  as plan,
        pc.mrr_delta                                as mrr_amount,
        case
            when pc.mrr_delta > 0 then 'Expansion'
            else 'Contraction'
        end                                         as mrr_type
    from plan_changes pc
),
all_movements as (
    select * from new_mrr
    union all
    select * from churned_mrr
    union all
    select * from expansion_mrr
),
enriched as (
    select
        m.month_start,
        format_date('%Y-%m', m.month_start)         as month_label,
        extract(year    from m.month_start)         as year,
        extract(month   from m.month_start)         as month_num,
        'Q' || cast(extract(quarter from m.month_start) as string) || ' '
            || cast(extract(year from m.month_start) as string) as quarter_label,
        dc.company_key,
        dp.plan_key,
        m.mrr_type,
        m.mrr_amount,
        m.company_id,
        m.plan
    from all_movements m
    left join dim_companies dc on m.company_id = dc.company_id
    left join dim_plans dp     on m.plan       = dp.plan_name
)
select * from enriched
order by month_start, mrr_type