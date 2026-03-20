with deals as (
    select * from main.stg_deals
),

companies as (
    select * from main.stg_companies
),

funnel as (
    select
        d.deal_id,
        d.company_id,
        c.company_name,
        c.segment,
        c.industry,
        d.plan,
        d.stage,
        d.amount,
        d.created_at,
        d.closed_at,
        d.is_closed,
        d.is_won,
        case
            when d.is_won then d.amount
            else 0
        end                                         as won_amount,
        case
            when d.closed_at is not null
            then cast(d.closed_at - d.created_at as integer)
            else null
        end                                         as days_to_close
    from deals d
    left join companies c on d.company_id = c.company_id
)

select * from funnel
