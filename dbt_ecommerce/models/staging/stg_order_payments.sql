with source as (
    select * from {{ source('ecommerce', 'order_payments') }}
),

deduped as (
    select *,
        row_number() over (
            partition by order_id, payment_sequential
            order by _loaded_at desc
        ) as rn
    from source
)

select
    cast(order_id as {{ dbt.type_string() }}) as order_id,
    cast(payment_sequential as {{ dbt.type_int() }}) as payment_sequential,
    cast(payment_type as {{ dbt.type_string() }}) as payment_type,
    cast(payment_installments as {{ dbt.type_int() }}) as payment_installments,
    cast(payment_value as {{ dbt.type_numeric() }}) as payment_value,
    -- Metadata
    cast(_loaded_at as {{ dbt.type_timestamp() }}) as _loaded_at
from deduped
where rn = 1