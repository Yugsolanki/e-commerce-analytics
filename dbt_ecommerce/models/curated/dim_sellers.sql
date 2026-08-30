with sellers as (
    select * from {{ ref('stg_sellers') }}
),

geolocation as (
    select * from {{ ref('int_geolocation_deduped') }}
)

select
    s.seller_id,
    s.seller_zip_code,
    s.seller_city,
    s.seller_state,
    g.geolocation_lat,
    g.geolocation_lng,
    -- Metadata
    cast(s._loaded_at as {{ dbt.type_timestamp() }}) as _loaded_at
from sellers s
left join geolocation g on s.seller_zip_code = g.geolocation_zip_code