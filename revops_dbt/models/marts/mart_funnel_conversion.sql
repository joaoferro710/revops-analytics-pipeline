with stage_history as (
    select * from main.stg_stage_history
),

deals as (
    select * from main.stg_deals
),

stage_order as (
    select 1 as order_num, 'Prospecting' as stage union all
    select 2,              'Qualified'            union all
    select 3,              'Proposal'             union all
    select 4,              'Negotiation'          union all
    select 5,              'Closed Won'
),

deals_per_stage as (
    select
        sh.stage,
        so.order_num,
        count(distinct sh.deal_id) as total_deals
    from stage_history sh
    left join stage_order so on sh.stage = so.stage
    where sh.stage != 'Closed Lost'
    group by sh.stage, so.order_num
),

conversion as (
    select
        curr.stage,
        curr.order_num,
        curr.total_deals,
        next_stage.total_deals as next_stage_deals,
        round(
            next_stage.total_deals * 100.0 / curr.total_deals,
            1
        ) as conversion_pct
    from deals_per_stage curr
    left join deals_per_stage next_stage
        on next_stage.order_num = curr.order_num + 1
)

select * from conversion
order by order_num
