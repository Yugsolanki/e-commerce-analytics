with source as (
    select * from {{ source('ecommerce', 'sellers') }}
),

deduped as (
    select *,
        row_number() over (
            partition by seller_id
            order by _loaded_at desc
        ) as rn
    from source
)

select
    cast(seller_id as {{ dbt.type_string() }}) as seller_id,
    cast(seller_zip_code_prefix as {{ dbt.type_string() }}) as seller_zip_code,
    cast(seller_city as {{ dbt.type_string() }}) as seller_city,
    cast(seller_state as {{ dbt.type_string() }}) as seller_state,
    -- Metadata
    cast(_loaded_at as {{ dbt.type_timestamp() }}) as _loaded_at
from deduped
where rn = 1