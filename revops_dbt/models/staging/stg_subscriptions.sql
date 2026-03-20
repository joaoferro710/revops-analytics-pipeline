with source as (
    select * from raw_subscriptions
),

renamed as (
    select
        subscription_id,
        company_id,
        deal_id,
        plan,
        mrr,
        status,
        cast(start_date as date)        as start_date,
        cast(end_date as date)          as end_date,
        case
            when status = 'Churned' then true
            else false
        end                             as is_churned
    from source
)

select * from renamed
