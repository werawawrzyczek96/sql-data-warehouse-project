/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys
    - Unwanted spaces in string fields
    - Data standardization and consistency
    - Invalid date ranges and orders
    - Data consistency between related fields

Usage Notes:
    - Run these checks after data loading Silver Layer
    - Investigate and resolve any discrepancies found during the checks
===============================================================================
*/

-- =============================================================================
-- Checking 'silver_crm_cust_info'
-- =============================================================================

-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    cst_id,
    COUNT(*)
FROM silver_crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check For Unwanted Spaces in String Fields
-- Expectation: No Results
SELECT cst_firstname, cst_lastname 
FROM silver_crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname) 
   OR cst_lastname != TRIM(cst_lastname);

-- Check Data Standardization (Gender & Marital Status)
-- Expectation: Only 'Male', 'Female', 'Single', 'Married', or 'n/a'
SELECT DISTINCT cst_gndr, cst_marital_status 
FROM silver_crm_cust_info
WHERE cst_gndr NOT IN ('Male', 'Female', 'n/a')
   OR cst_marital_status NOT IN ('Single', 'Married', 'n/a');


-- =============================================================================
-- Checking 'silver_crm_prd_info'
-- =============================================================================

-- Check For Nulls or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    prd_id,
    COUNT(*)
FROM silver_crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check Invalid Date Ranges (Start Date after End Date)
-- Expectation: No Results
SELECT prd_id, prd_nm, prd_start_dt, prd_end_dt 
FROM silver_crm_prd_info
WHERE prd_start_dt > prd_end_dt;

-- Check For Negative Product Costs
-- Expectation: No Results
SELECT prd_id, prd_nm, prd_cost 
FROM silver_crm_prd_info
WHERE prd_cost < 0;


-- =============================================================================
-- Checking 'silver_crm_sales_details'
-- =============================================================================

-- Check For Nulls in Crucial Fields
-- Expectation: No Results
SELECT * 
FROM silver_crm_sales_details
WHERE sls_ord_num IS NULL 
   OR sls_prd_key IS NULL 
   OR sls_cust_id IS NULL;

-- Check Invalid Date Orders (Order Date after Shipping Date)
-- Expectation: No Results
SELECT sls_ord_num, sls_order_dt, sls_ship_dt 
FROM silver_crm_sales_details
WHERE sls_order_dt > sls_ship_dt;

-- Check Data Consistency Between Related Fields (Sales = Qty * Price)
-- Expectation: No Results
SELECT sls_ord_num, sls_sales, sls_quantity, sls_price 
FROM silver_crm_sales_details
WHERE sls_sales != (sls_quantity * sls_price)
  AND sls_quantity > 0;


-- =============================================================================
-- Checking 'silver_erp_cust_az12'
-- =============================================================================

-- Check For Nulls or Duplicates in Business Key
-- Expectation: No Results
SELECT cid, COUNT(*) 
FROM silver_erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1 OR cid IS NULL;

-- Check For Future Birth Dates (Invalid Dates)
-- Expectation: No Results
SELECT cid, bdate 
FROM silver_erp_cust_az12
WHERE bdate > NOW();


-- =============================================================================
-- Checking 'silver_erp_loc_a101'
-- =============================================================================

-- Check For Formatting/Spaces in Country Code or ID
-- Expectation: No Results
SELECT cid, cntry 
FROM silver_erp_loc_a101
WHERE cid LIKE '%-%' 
   OR cntry != TRIM(cntry);


-- =============================================================================
-- Checking 'silver_erp_px_cat_g1v2'
-- =============================================================================

-- Check For Nulls or Duplicates in Key
-- Expectation: No Results
SELECT id, COUNT(*) 
FROM silver_erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1 OR id IS NULL;

