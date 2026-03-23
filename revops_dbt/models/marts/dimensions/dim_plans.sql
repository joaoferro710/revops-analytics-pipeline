with plans as (
    select distinct plan from main.stg_deals
)

select
    row_number() over (order by
        case plan
            when 'Starter'    then 1
            when 'Growth'     then 2
            when 'Pro'        then 3
            when 'Enterprise' then 4
        end
    )                                               as plan_key,
    plan                                            as plan_name,
    case plan
        when 'Starter'    then 199
        when 'Growth'     then 599
        when 'Pro'        then 1499
        when 'Enterprise' then 3999
    end                                             as mrr_value,
    case plan
        when 'Starter'    then 'Entry'
        when 'Growth'     then 'Mid'
        when 'Pro'        then 'Mid'
        when 'Enterprise' then 'Enterprise'
    end                                             as tier,
    case plan
        when 'Enterprise' then true
        else false
    end                                             as is_enterprise
from plans
