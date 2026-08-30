with source as (
    select * from {{ source('ecommerce', 'customers') }}
)

select 
    cast(customer_id as {{ dbt.type_string() }}) as customer_id,
    cast(customer_unique_id as {{ dbt.type_string() }}) as customer_unique_id,
    cast(customer_zip_code_prefix as {{ dbt.type_string() }}) as customer_zip_code,
    cast(customer_city as {{ dbt.type_string() }}) as customer_city,
    cast(customer_state as {{ dbt.type_string() }}) as customer_state,
    -- Metadata
    cast(_loaded_at as {{ dbt.type_timestamp() }}) as _loaded_at
from source
