with stage_history as (
    select * from main.stg_stage_history
),

deals as (
    select * from main.stg_deals
),

companies as (
    select * from main.stg_companies
),

stage_order as (
    select 1 as order_num, 'Prospecting' as stage union all
    select 2,              'Qualified'            union all
    select 3,              'Proposal'             union all
    select 4,              'Negotiation'          union all
    select 5,              'Closed Won'
),

deal_attrs as (
    select
        d.deal_id,
        d.plan,
        c.segment,
        c.industry,
        'Q' || quarter(d.created_at) || ' ' || year(d.created_at) as deal_quarter,
        year(d.created_at)                                          as deal_year
    from deals d
    left join companies c on d.company_id = c.company_id
),

history_enriched as (
    select
        sh.deal_id,
        sh.stage,
        sh.entered_at,
        so.order_num,
        da.plan,
        da.segment,
        da.industry,
        da.deal_quarter,
        da.deal_year
    from stage_history sh
    left join stage_order so on sh.stage = so.stage
    left join deal_attrs da  on sh.deal_id = da.deal_id
    where sh.stage != 'Closed Lost'
),

deals_per_stage as (
    select
        stage,
        order_num,
        plan,
        segment,
        industry,
        deal_quarter,
        deal_year,
        count(distinct deal_id) as total_deals
    from history_enriched
    group by stage, order_num, plan, segment, industry, deal_quarter, deal_year
),

conversion as (
    select
        curr.stage                      as from_stage,
        curr.order_num                  as from_order,
        next_s.stage                    as to_stage,
        curr.plan,
        curr.segment,
        curr.industry,
        curr.deal_quarter,
        curr.deal_year,
        curr.total_deals                as deals_entered,
        coalesce(next_s.total_deals, 0) as deals_advanced,
        round(
            coalesce(next_s.total_deals, 0) * 100.0 / curr.total_deals,
            1
        )                               as conversion_pct
    from deals_per_stage curr
    left join deals_per_stage next_s
        on  next_s.order_num    = curr.order_num + 1
        and next_s.plan         = curr.plan
        and next_s.segment      = curr.segment
        and next_s.industry     = curr.industry
        and next_s.deal_quarter = curr.deal_quarter
        and next_s.deal_year    = curr.deal_year
)

select * from conversion
order by from_order, segment, plan, deal_year
