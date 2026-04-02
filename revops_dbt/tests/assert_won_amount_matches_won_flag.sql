select *
from {{ ref('fact_deals') }}
where (is_won = true and won_amount != amount)
   or (is_won = false and won_amount != 0)
