-- grain: one row per product

with source as (
    select * from {{ ref('stg_products') }}
)

select 
    s.product_id,
    t.product_category_name_english as product_category_name,
    s.product_name_length,
    s.product_description_length,
    s.product_photos_qty,
    s.product_weight_g,
    s.product_length_cm,
    s.product_height_cm,
    s.product_width_cm,
    -- Metadata
    cast(s._loaded_at as {{ dbt.type_timestamp() }}) as _loaded_at
from source as s
left join {{ ref('stg_product_category_name_translation') }} as t on s.product_category_name = t.product_category_name
