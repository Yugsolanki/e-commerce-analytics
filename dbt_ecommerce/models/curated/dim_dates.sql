with spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2016-01-01' as date)",
        end_date="cast('2019-12-31' as date)"
    ) }}
)

select
    cast(date_day as date) as date_day,
    cast(to_char(date_day, 'YYYYMMDD') as int) as date_id,
    extract(year from date_day) as year_number,
    extract(quarter from date_day) as quarter_of_year,
    extract(month from date_day) as month_of_year,
    trim(to_char(date_day, 'Month')) as month_name,
    trim(to_char(date_day, 'Day')) as day_name,
    extract(dow from date_day) as day_of_week,
    extract(week from date_day) as week_of_year,
    to_char(date_day, 'YYYY-MM') as year_month,
    case when extract(dow from date_day) in (0, 6) then true else false end as is_weekend
from spine