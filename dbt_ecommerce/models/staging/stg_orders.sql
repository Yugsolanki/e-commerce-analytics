with source as (
    select * from {{ source('ecommerce', 'orders') }}
)

select
    cast(order_id as {{ dbt.type_string() }}) as order_id,
    cast(customer_id as {{ dbt.type_string() }}) as customer_id,
    cast(order_status as {{ dbt.type_string() }}) as order_status,
    cast(order_purchase_timestamp as {{ dbt.type_timestamp() }}) as order_purchase_timestamp,
    cast(order_approved_at as {{ dbt.type_timestamp() }}) as order_approved_at,
    cast(order_delivered_carrier_date as {{ dbt.type_timestamp() }}) as order_delivered_carrier_date,
    cast(order_delivered_customer_date as {{ dbt.type_timestamp() }}) as order_delivered_customer_date,
    cast(order_estimated_delivery_date as {{ dbt.type_timestamp() }}) as order_estimated_delivery_date,
    -- Metadata
    cast(ingestion_timestamp as {{ dbt.type_timestamp() }}) as ingestion_timestamp
from source