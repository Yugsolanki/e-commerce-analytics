with customers as (
    select * from {{ ref('stg_customers') }}
),

geolocation as (
    select * from {{ ref('int_geolocation_deduped') }}
)

select
    c.customer_id,
    c.customer_unique_id,
    c.customer_zip_code,
    c.customer_city,
    c.customer_state,
    g.geolocation_lat,
    g.geolocation_lng
from customers c
left join geolocation g on c.customer_zip_code = g.geolocation_zip_code