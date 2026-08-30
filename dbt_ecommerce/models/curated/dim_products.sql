with products as (
    select * from {{ ref('int_products_enriched') }}
),

translation as (
    select * from {{ ref('stg_product_category_name_translation') }}
)

select
    p.product_id,
    coalesce(t.product_category_name_english, p.product_category_name, 'unknown') as product_category,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,
    p.product_length_cm * p.product_height_cm * p.product_width_cm as product_volume_cm3,
    -- Metadata
    cast(p._loaded_at as {{ dbt.type_timestamp() }}) as _loaded_at
from products p
left join translation t on p.product_category_name = t.product_category_name