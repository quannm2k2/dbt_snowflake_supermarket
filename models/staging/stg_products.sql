WITH source_data AS (
    SELECT
        product_id,
        product_name,
        category,
        price
    FROM {{ source('supermarket', 'products') }}
)
SELECT
    product_id,
    product_name,
    category,
    ROUND(price, 2) AS price
FROM source_data
