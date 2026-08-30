with order_items as (
    select * from {{ ref('stg_order_items') }}
),

orders as (
    select order_id, customer_id, order_purchase_timestamp, order_status
    from {{ ref('int_orders_enriched') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['i.order_id', 'i.order_item_id']) }} as order_item_key,
    i.order_id,
    i.order_item_id,
    o.customer_id,
    cast(o.order_purchase_timestamp as date) as order_purchase_date,
    i.product_id,
    i.seller_id,
    i.shipping_limit_date,
    i.price,
    i.freight_value,
    i.price + i.freight_value as line_total,
    -- Metadata
    cast(i._loaded_at as {{ dbt.type_timestamp() }}) as _loaded_at
from order_items i
left join orders o on i.order_id = o.order_id