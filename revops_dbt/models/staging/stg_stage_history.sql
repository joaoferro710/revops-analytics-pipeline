with source as (
    select * from raw_stage_history
),

renamed as (
    select
        deal_id,
        stage,
        cast(entered_at as date) as entered_at
    from source
)

select * from renamed
