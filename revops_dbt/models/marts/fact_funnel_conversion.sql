with stage_history as (
    select * from {{ ref('stg_stage_history') }}
),

stage_order as (
    select * from {{ ref('dim_stages') }}
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

deals as (
    select * from {{ ref('stg_deals') }}
),

deal_attrs as (
    select
        d.deal_id,
        dc.company_key,
        dp.plan_key,
        cast(strftime(d.created_at, '%Y%m%d') as integer) as date_key
    from deals d
    left join dim_companies dc on d.company_id = dc.company_id
    left join dim_plans dp     on d.plan       = dp.plan_name
),

history_enriched as (
    select
        sh.deal_id,
        sh.stage,
        so.stage_key,
        so.stage_order,
        da.company_key,
        da.plan_key,
        da.date_key
    from stage_history sh
    left join stage_order so on sh.stage   = so.stage_name
    left join deal_attrs  da on sh.deal_id = da.deal_id
    where sh.stage != 'Closed Lost'
),

deals_per_stage as (
    select
        stage,
        stage_key,
        stage_order,
        company_key,
        plan_key,
        date_key,
        count(distinct deal_id) as deals_entered
    from history_enriched
    group by stage, stage_key, stage_order, company_key, plan_key, date_key
),

conversion as (
    select
        curr.stage_key                              as from_stage_key,
        next_s.stage_key                            as to_stage_key,
        curr.company_key,
        curr.plan_key,
        curr.date_key,
        curr.deals_entered,
        coalesce(next_s.deals_entered, 0)           as deals_advanced,
        round(
            coalesce(next_s.deals_entered, 0) * 100.0
            / nullif(curr.deals_entered, 0),
            2
        )                                           as conversion_pct
    from deals_per_stage curr
    left join deals_per_stage next_s
        on  next_s.stage_order  = curr.stage_order + 1
        and next_s.company_key  = curr.company_key
        and next_s.plan_key     = curr.plan_key
        and next_s.date_key     = curr.date_key
    where curr.stage_order < 5
)

select * from conversion
