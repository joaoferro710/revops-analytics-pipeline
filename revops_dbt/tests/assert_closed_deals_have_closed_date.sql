select *
from {{ ref('stg_deals') }}
where is_closed = true
  and closed_at is null
