with source as (
    select * from {{ source('ecommerce', 'order_reviews') }}
)

select
    cast(review_id as {{ dbt.type_string() }}) as review_id,
    cast(order_id as {{ dbt.type_string() }}) as order_id,
    cast(review_score as {{ dbt.type_int() }}) as score,
    cast(review_comment_title as {{ dbt.type_string() }}) as review_comment_title,
    cast(review_comment_message as {{ dbt.type_string() }}) as review_comment_message,
    cast(review_creation_date as {{ dbt.type_timestamp() }}) as review_creation_date,
    cast(review_answer_timestamp as {{ dbt.type_timestamp() }}) as review_answer_timestamp,
    -- Metadata
    cast(ingestion_timestamp as {{ dbt.type_timestamp() }}) as ingestion_timestamp
from source