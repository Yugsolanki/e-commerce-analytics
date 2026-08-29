-- grain: one row per zip code

with source as (
    select * from {{ ref('stg_geolocation') }}
)

select
    geolocation_zip_code,
    avg(geolocation_lat) as geolocation_lat,
    avg(geolocation_lng) as geolocation_lng,
    min(geolocation_city)  as geolocation_city,
    min(geolocation_state) as geolocation_state
from source
group by geolocation_zip_code