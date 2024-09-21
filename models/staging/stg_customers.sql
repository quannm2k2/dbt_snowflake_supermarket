WITH source_data AS (
    SELECT
        customer_id,
        first_name,
        last_name,
        email,
        phone_number,
        registered_at
    FROM {{ source('supermarket', 'customers') }}
)
SELECT
    customer_id,
    LOWER(email) AS email,
    CONCAT(first_name, ' ', last_name) AS full_name,
    phone_number,
    DATE(registered_at) AS registered_at
FROM source_data
WHERE email IS NOT NULL
