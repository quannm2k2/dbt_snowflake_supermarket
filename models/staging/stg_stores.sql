WITH source_data AS (
    SELECT
        store_id,
        store_name,
        location
    FROM {{ source('supermarket', 'stores') }}
)
SELECT
    *
FROM source_data
