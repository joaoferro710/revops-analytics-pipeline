with date_spine as (
    select range as date_day
    from range(date '2022-01-01', date '2025-12-31', interval '1 day')
)

select
    cast(strftime(date_day, '%Y%m%d') as integer)   as date_key,
    date_day                                         as full_date,
    year(date_day)                                   as year,
    quarter(date_day)                                as quarter_num,
    'Q' || quarter(date_day) || ' ' || year(date_day) as quarter_label,
    month(date_day)                                  as month_num,
    strftime(date_day, '%B')                         as month_name,
    strftime(date_day, '%Y-%m')                      as year_month,
    dayofweek(date_day)                              as day_of_week,
    strftime(date_day, '%A')                         as day_name,
    dayofyear(date_day)                              as day_of_year,
    weekofyear(date_day)                             as week_of_year,
    case when dayofweek(date_day) in (0,6) then true else false end as is_weekend
from date_spine
