{% macro test_customer_order_summary() %}
    -- Macro để kiểm tra xem mỗi khách hàng trong bảng customer_order_summary có tổng số giao dịch
    -- và tổng số tiền chi tiêu (total_spent) chính xác không.

    WITH customer_orders AS (
        -- Lấy tất cả các giao dịch và tổng số tiền cho từng khách hàng
        SELECT 
            customer_id,
            COUNT(*) AS total_transactions,
            SUM(quantity * price) AS total_spent
        FROM {{ ref('stg_transactions') }} AS t
        JOIN {{ ref('stg_products') }} AS p
        ON t.product_id = p.product_id
        GROUP BY customer_id
    )
    
    -- So sánh kết quả tổng hợp từ bảng gốc với bảng customer_order_summary
    SELECT
        cos.customer_id,
        cos.total_transactions AS summary_total_transactions,
        co.total_transactions AS calculated_total_transactions,
        cos.total_spent AS summary_total_spent,
        co.total_spent AS calculated_total_spent
    FROM {{ ref('customer_order_summary') }} AS cos
    LEFT JOIN customer_orders AS co
    ON cos.customer_id = co.customer_id
    WHERE 
        cos.total_transactions != co.total_transactions
        OR cos.total_spent != co.total_spent
{% endmacro %}
