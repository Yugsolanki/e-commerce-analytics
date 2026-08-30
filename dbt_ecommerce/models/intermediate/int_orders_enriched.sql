-- grain: one row per order

with source as (
    select * from {{ ref('stg_orders') }}
)

select
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    
    -- nulls here are meaningful
    {{ dbt.datediff('order_purchase_timestamp', 'order_approved_at', 'hour') }} as hours_to_approval,
    {{ dbt.datediff('order_purchase_timestamp', 'order_delivered_customer_date', 'day') }} as days_to_delivery,

    -- on time performace
    order_delivered_customer_date > order_estimated_delivery_date as is_late,
    {{ dbt.datediff('order_estimated_delivery_date', 'order_delivered_customer_date', 'day') }} as delay_days,

    -- Metadata
    cast(ingestion_timestamp as {{ dbt.type_timestamp() }}) as ingestion_timestamp
from source