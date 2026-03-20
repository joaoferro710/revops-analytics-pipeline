with source as (
    select * from raw_activities
),

renamed as (
    select
        activity_id,
        deal_id,
        contact_id,
        type                            as activity_type,
        outcome,
        cast(date as date)              as activity_date
    from source
)

select * from renamed