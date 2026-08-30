with source as (
    select * from {{ source('ecommerce', 'product_category_name_translation') }}
),

deduped as (
    select *,
        row_number() over (
            partition by product_category_name
            order by _loaded_at desc
        ) as rn
    from source
)

select
    cast(product_category_name as {{ dbt.type_string() }}) as product_category_name,
    cast(product_category_name_english as {{ dbt.type_string() }}) as product_category_name_english,
    -- Metadata
    cast(_loaded_at as {{ dbt.type_timestamp() }}) as _loaded_at
from deduped
where rn = 1