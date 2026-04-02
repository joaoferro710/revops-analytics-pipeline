with date_spine as (
    select date_add(date '2022-01-01', interval cast(n as int64) day) as date_day
    from unnest(generate_array(0, date_diff(date '2025-12-31', date '2022-01-01', DAY))) as n
)
select
    cast(format_date('%Y%m%d', date_day) as int64)      as date_key,
    date_day                                             as full_date,
    extract(year    from date_day)                       as year,
    extract(quarter from date_day)                       as quarter_num,
    'Q' || cast(extract(quarter from date_day) as string) || ' ' ||
    cast(extract(year from date_day) as string)          as quarter_label,
    extract(month   from date_day)                       as month_num,
    format_date('%B', date_day)                          as month_name,
    format_date('%Y-%m', date_day)                       as year_month,
    extract(dayofweek from date_day)                     as day_of_week,
    format_date('%A', date_day)                          as day_name,
    extract(dayofyear from date_day)                     as day_of_year,
    extract(isoweek  from date_day)                      as week_of_year,
    case when extract(dayofweek from date_day) in (1,7) then true else false end as is_weekend
from date_spine