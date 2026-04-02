with source as (
    select * from {{ source('revops_raw', 'companies') }}
),
renamed as (
    select
        company_id,
        name                            as company_name,
        segment,
        industry,
        employees,
        city,
        state,
        cast(created_at as date)        as created_at
    from source
)
select * from renamed