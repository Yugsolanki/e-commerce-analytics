-- grain: one row per order that has at least one review

with source as (
    select * from {{ ref('stg_order_reviews') }}
)

select
    order_id,
    count(*) as review_count,
    avg(score) as avg_review_score,
    count(review_comment_message) as commented_review_count
from source
group by order_id