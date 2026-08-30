with source as (
    select * from {{ source('ecommerce', 'product_category_name_translation') }}
)

select
    cast(product_category_name as {{ dbt.type_string() }}) as product_category_name,
    cast(product_category_name_english as {{ dbt.type_string() }}) as product_category_name_english,
    -- Metadata
    cast(_loaded_at as {{ dbt.type_timestamp() }}) as _loaded_at
from source