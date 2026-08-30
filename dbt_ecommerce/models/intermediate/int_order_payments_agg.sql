-- grain: one row per order

with source as (
    select * from {{ ref('stg_order_payments') }}
)

select
    order_id,
    count(*) as payment_count,
    sum(payment_value) as payment_value_total,
    max(payment_installments) as installments_max,
    (array_agg(payment_type order by payment_value desc))[1] as primary_payment_type,
    sum(case when payment_type = 'credit_card' then payment_value else 0 end) as credit_card_value,
    -- Metadata
    cast(max(ingestion_timestamp) as {{ dbt.type_timestamp() }}) as ingestion_timestamp
from source
group by order_id