-- grain: one row per order

with source as (
    select * from {{ ref('int_orders_enriched') }}
)

select
    s.*,
    c.customer_unique_id,
    c.customer_zip_code,
    c.customer_city,
    c.customer_state,
    it.order_value_total,
    it.freight_total,
    pay.payment_value_total,
    pay.primary_payment_type,
    rv.avg_review_score

from source s
inner join {{ ref('stg_customers') }} c on s.customer_id = c.customer_id
left join {{ ref('int_order_items_agg') }} it on s.order_id = it.order_id
left join {{ ref('int_order_payments_agg') }} pay on s.order_id = pay.order_id
left join {{ ref('int_order_reviews_agg') }} rv on s.order_id = rv.order_id