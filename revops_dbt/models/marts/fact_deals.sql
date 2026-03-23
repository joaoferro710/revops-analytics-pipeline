with deals as (
    select * from main.stg_deals
),

companies as (
    select * from main.stg_companies
),

dim_companies as (
    select * from main.dim_companies
),

dim_plans as (
    select * from main.dim_plans
),

dim_stages as (
    select * from main.dim_stages
),

dim_dates as (
    select * from main.dim_dates
),

fact as (
    select
        -- Chaves surrogate
        dc.company_key,
        dp.plan_key,
        ds.stage_key,
        coalesce(dd_created.date_key, -1)           as created_date_key,
        coalesce(dd_closed.date_key, -1)            as closed_date_key,

        -- Chave natural
        d.deal_id,

        -- Metricas
        d.amount,
        case when d.is_won then d.amount else 0 end as won_amount,
        case
            when d.closed_at is not null
            then cast(d.closed_at - d.created_at as integer)
            else null
        end                                         as days_to_close,
        d.is_won,
        d.is_closed,
        case when not d.is_closed then true else false end as is_open,

        -- Atributos degenerados (sem dimensao propria)
        d.stage,
        d.plan,
        c.segment,
        c.industry

    from deals d
    left join companies c       on d.company_id   = c.company_id
    left join dim_companies dc  on d.company_id   = dc.company_id
    left join dim_plans dp      on d.plan         = dp.plan_name
    left join dim_stages ds     on d.stage        = ds.stage_name
    left join dim_dates dd_created on cast(strftime(d.created_at, '%Y%m%d') as integer) = dd_created.date_key
    left join dim_dates dd_closed  on cast(strftime(d.closed_at,  '%Y%m%d') as integer) = dd_closed.date_key
)

select * from fact
