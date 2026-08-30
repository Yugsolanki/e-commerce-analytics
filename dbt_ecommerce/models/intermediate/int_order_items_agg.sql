-- grain: one row per order

with source as (
    select * from {{ ref('stg_order_items') }}
)

select
    order_id,
    count(*)                        as item_count,
    count(distinct product_id)      as product_count,
    count(distinct seller_id)       as seller_count,
    sum(price)                      as item_value_total,
    sum(freight_value)              as freight_total,
    sum(price + freight_value)      as order_value_total,
    -- Metadata
    cast(max(_loaded_at) as {{ dbt.type_timestamp() }}) as _loaded_at
from source
group by order_id