with source as (
    select * from {{ source('ecommerce', 'order_payments') }}
)

select
    cast(order_id as {{ dbt.type_string() }}) as order_id,
    cast(payment_sequential as {{ dbt.type_int() }}) as payment_sequential,
    cast(payment_type as {{ dbt.type_string() }}) as payment_type,
    cast(payment_installments as {{ dbt.type_int() }}) as payment_installments,
    cast(payment_value as {{ dbt.type_numeric() }}) as payment_value,
    -- Metadata
    cast(ingestion_timestamp as {{ dbt.type_timestamp() }}) as ingestion_timestamp
from source