with orders as (
    select * from {{ ref('int_orders_enriched') }}
),

items as (
    select * from {{ ref('int_order_items_agg') }}
),

payments as (
    select * from {{ ref('int_order_payments_agg') }}
),

reviews as (
    select * from {{ ref('int_order_reviews_agg') }}
)

select
    -- keys
    o.order_id,
    o.customer_id,
    cast(o.order_purchase_timestamp as date) as order_purchase_date,
    cast(o.order_delivered_customer_date as date) as delivered_date,

    -- state & timestamps
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    -- item measures
    coalesce(i.item_count, 0) as item_count,
    coalesce(i.product_count, 0) as product_count,
    coalesce(i.seller_count, 0) as seller_count,
    i.item_value_total,
    i.freight_total,
    i.order_value_total,

    -- payment measures
    p.payment_count,
    p.payment_value_total,
    p.installments_max,
    p.primary_payment_type,

    -- review measures
    r.review_count,
    r.avg_review_score,
    r.commented_review_count,

    -- service measures
    o.hours_to_approval,
    o.days_to_delivery,
    o.is_late,
    o.delay_days
from orders o
left join items    i on o.order_id = i.order_id
left join payments p on o.order_id = p.order_id
left join reviews  r on o.order_id = r.order_id