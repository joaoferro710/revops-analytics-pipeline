with companies as (
    select * from main.stg_companies
)

select
    row_number() over (order by company_id)         as company_key,
    company_id,
    company_name,
    segment,
    industry,
    employees,
    case
        when employees < 50   then 'Micro'
        when employees < 200  then 'Small'
        when employees < 1000 then 'Medium'
        else 'Large'
    end                                             as company_size,
    city,
    state,
    created_at
from companies
