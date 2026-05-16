/*
===============================================================================
Quality Checks - Gold Layer
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency 
    and accuracy of the Gold layer. 
    These checks ensure:
    - Uniqueness of surrogate keys in dimension tables
    - Referential integrity between fact and dimension tables
    - Validation of relationships in the data model for analytical purposes

Usage Notes:
    - Run these checks after loading the Gold Layer (Views / Tables)
    - Investigate and resolve any discrepancies found during the checks
===============================================================================
*/

-- =============================================================================
-- Checking 'gold_dim_customers'
-- =============================================================================

-- Check For Uniqueness of Customer Key in gold_dim_customers
-- Expectation: No Results
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold_dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- =============================================================================
-- Checking 'gold_dim_products'
-- =============================================================================

-- Check For Uniqueness of Product Key in gold_dim_products
-- Expectation: No Results
SELECT
    product_key, -- Fixed: Added missing comma after column name
    COUNT(*) AS duplicate_count
FROM gold_dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- =============================================================================
-- Checking 'gold_fact_sales' (Referential Integrity)
-- =============================================================================

-- Check data model connectivity between fact and dimensions
-- Detects orphaned records in the fact table (keys that do not exist in dimensions)
-- Expectation: No Results
SELECT 
    f.order_number,
    f.customer_key AS fact_customer_key,
    f.product_key AS fact_product_key
FROM gold_fact_sales f
LEFT JOIN gold_dim_customers c
    ON c.customer_key = f.customer_key
LEFT JOIN gold_dim_products p
    ON p.product_key = f.product_key
WHERE c.customer_key IS NULL 
   OR p.product_key IS NULL;
