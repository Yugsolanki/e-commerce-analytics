with source as (
    select * from {{ source('ecommerce', 'geolocation') }}
)

select
    cast(geolocation_zip_code_prefix as {{ dbt.type_string() }}) as geolocation_zip_code,
    cast(geolocation_lat as {{ dbt.type_numeric() }}) as geolocation_lat,
    cast(geolocation_lng as {{ dbt.type_numeric() }}) as geolocation_lng,
    cast(geolocation_city as {{ dbt.type_string() }}) as geolocation_city,
    cast(geolocation_state as {{ dbt.type_string() }}) as geolocation_state,
    -- Metadata
    cast(_loaded_at as {{ dbt.type_timestamp() }}) as _loaded_at
from source