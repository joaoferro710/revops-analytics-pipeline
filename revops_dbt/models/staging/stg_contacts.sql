with source as (
    select * from raw_contacts
),

renamed as (
    select
        contact_id,
        company_id,
        name                            as contact_name,
        email,
        role,
        cast(created_at as date)        as created_at
    from source
)

select * from renamed
