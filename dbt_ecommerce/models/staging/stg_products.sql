with source as (
    select * from {{ source('ecommerce', 'products') }}
),

deduped as (
    select *,
        row_number() over (
            partition by product_id
            order by _loaded_at desc
        ) as rn
    from source
)

select
    cast(product_id as {{ dbt.type_string() }}) as product_id,
    cast(product_category_name as {{ dbt.type_string() }}) as product_category_name,
    cast(product_name_length as {{ dbt.type_int() }}) as product_name_length,
    cast(product_description_length as {{ dbt.type_int() }}) as product_description_length,
    cast(product_photos_qty as {{ dbt.type_int() }}) as product_photos_qty,
    cast(product_weight_g as {{ dbt.type_int() }}) as product_weight_g,
    cast(product_length_cm as {{ dbt.type_int() }}) as product_length_cm,
    cast(product_height_cm as {{ dbt.type_int() }}) as product_height_cm,
    cast(product_width_cm as {{ dbt.type_int() }}) as product_width_cm,
    -- Metadata
    cast(_loaded_at as {{ dbt.type_timestamp() }}) as _loaded_at
from deduped
where rn = 1
