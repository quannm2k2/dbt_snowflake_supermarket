{{ config(required_docs=false, required_tests=None) }}

WITH store_sales AS (
    SELECT
        stg.store_id,
        COUNT(stg.transaction_id) AS total_transactions,
        SUM(stg.quantity) AS total_items_sold,
        SUM(stg.quantity * prod.price) AS total_revenue
    FROM {{ ref('stg_transactions') }} AS stg
    JOIN {{ ref('stg_products') }} AS prod ON stg.product_id = prod.product_id
    GROUP BY stg.store_id
)
SELECT
    store.store_id,
    store.store_name,
    COALESCE(ss.total_transactions, 0) AS total_transactions,
    COALESCE(ss.total_items_sold, 0) AS total_items_sold,
    COALESCE(ss.total_revenue, 0) AS total_revenue
FROM {{ ref('stg_stores') }} AS store
LEFT JOIN store_sales AS ss ON store.store_id = ss.store_id
