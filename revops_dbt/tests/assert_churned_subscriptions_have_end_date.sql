select *
from {{ ref('stg_subscriptions') }}
where status = 'Churned'
  and end_date is null
