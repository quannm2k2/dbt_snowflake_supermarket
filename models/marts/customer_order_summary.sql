WITH customer_transactions AS (
    SELECT
        stg.customer_id,
        COUNT(stg.transaction_id) AS total_transactions,
        SUM(stg.quantity) AS total_items_bought,
        SUM(stg.quantity * prod.price) AS total_spent
    FROM {{ ref('stg_transactions') }} AS stg
    JOIN {{ ref('stg_products') }} AS prod ON stg.product_id = prod.product_id
    GROUP BY stg.customer_id
)
SELECT
    cust.customer_id,
    cust.full_name,
    cust.email,
    cust.phone_number,
    cust.registered_at,
    COALESCE(ct.total_transactions, 0) AS total_transactions,
    COALESCE(ct.total_items_bought, 0) AS total_items_bought,
    COALESCE(ct.total_spent, 0) AS total_spent
FROM {{ ref('stg_customers') }} AS cust
LEFT JOIN customer_transactions AS ct ON cust.customer_id = ct.customer_id
