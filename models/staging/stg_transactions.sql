WITH source_data AS (
    SELECT
        transaction_id,
        customer_id,
        product_id,
        store_id,
        quantity,
        transaction_date
    FROM {{ source('supermarket', 'transactions') }}
)
SELECT
    transaction_id,
    customer_id,
    product_id,
    store_id,
    quantity,
    DATE(transaction_date) AS transaction_date
FROM source_data
WHERE quantity > 0
