with source as (
    select * from raw_deals
),

renamed as (
    select
        deal_id,
        company_id,
        plan,
        stage,
        amount,
        cast(created_at as date)        as created_at,
        cast(closed_at as date)         as closed_at,
        case
            when stage = 'Closed Won'  then true
            when stage = 'Closed Lost' then true
            else false
        end                             as is_closed,
        case
            when stage = 'Closed Won'  then true
            else false
        end                             as is_won
    from source
)

select * from renamed
