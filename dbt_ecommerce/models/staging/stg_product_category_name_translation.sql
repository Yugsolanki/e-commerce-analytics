with source as (
    select * from {{ source('ecommerce', 'product_category_name_translation') }}
)

select
    cast(product_category_name as {{ dbt.type_string() }}) as product_category_name,
    cast(product_category_name_english as {{ dbt.type_string() }}) as product_category_name_english,
    -- Metadata
    cast(ingestion_timestamp as {{ dbt.type_timestamp() }}) as ingestion_timestamp
from source