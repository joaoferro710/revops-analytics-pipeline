select *
from {{ ref('stg_subscriptions') }}
where status = 'Active'
  and end_date is not null
