with source as (
    select * from raw_plan_changes
),

renamed as (
    select
        change_id,
        subscription_id,
        company_id,
        from_plan,
        to_plan,
        from_mrr,
        to_mrr,
        mrr_delta,
        change_type,
        cast(change_date as date) as change_date
    from source
)

select * from renamed
