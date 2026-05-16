/*
===============================================================================
Data Loading Script: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This script loads and transforms raw data from the Bronze layer into the 
    Silver layer. It applies data cleaning, handles formatting issues, 
    normalizes code values into readable formats, and removes duplicate records.

Technical Note:
    In MySQL, the default strict mode prevents processing '0000-00-00' dates 
    from raw exports. We set SESSION sql_mode to empty to temporarily disable 
    'NO_ZERO_DATE' so we can safely clean and convert them into proper NULLs.
===============================================================================
*/

SET SESSION sql_mode = '';

-- FOR CRM.CUST info
TRUNCATE TABLE silver_crm_cust_info;
INSERT INTO silver_crm_cust_info (
	cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date)
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_fristname,
TRIM(cst_lastname) AS cst_lastname,
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
    ELSE 'n/a'
END AS cst_marital_status, -- Normalize marital status values to readable format
CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
    ELSE 'n/a'
END AS cst_gndr, -- Normalize gender values to readable format
CASE 
        WHEN cst_create_date = '0000-00-00' THEN NULL 
        ELSE cst_create_date 
    END AS cst_create_date 
FROM (
SELECT
*,
ROW_NUMBER () OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_last
FROM bronze_crm_cust_info
)t WHERE flag_last =1; -- Select the most recent record per customer (removing duplicates)


-- For CRM.PRD info
TRUNCATE TABLE silver_crm_prd_info;
INSERT INTO silver_crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt)
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, CHAR_LENGTH(prd_key)) AS new_prd_key,
    prd_nm,
    IFNULL (prd_cost, 0) AS prd_cost,
    CASE UPPER(TRIM(prd_line))
		WHEN 'M' THEN 'Mountain'
		WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a'
	END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST(DATE_SUB(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt), INTERVAL 1 DAY) AS DATE) AS prd_end_dt
FROM bronze_crm_prd_info;

-- FOR CRM.SALES info
TRUNCATE TABLE silver_crm_sales_details;
INSERT INTO silver_crm_sales_details(
	sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE WHEN sls_order_dt = 0
             OR CHAR_LENGTH(sls_order_dt) != 8
        THEN NULL
        ELSE STR_TO_DATE(sls_order_dt, '%Y%m%d')
    END AS sls_order_dt,
    CASE
        WHEN sls_ship_dt = 0
             OR CHAR_LENGTH(sls_ship_dt) != 8
        THEN NULL
        ELSE STR_TO_DATE(sls_ship_dt, '%Y%m%d')
    END AS sls_ship_dt,
    CASE
        WHEN sls_due_dt = 0
             OR CHAR_LENGTH(sls_due_dt) != 8
        THEN NULL
        ELSE STR_TO_DATE(sls_due_dt, '%Y%m%d')
    END AS sls_due_dt,
    CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,
	sls_quantity,
CASE WHEN sls_price IS NULL OR sls_price <=0 
		THEN sls_price / NULLIF(sls_quantity,0)
	ELSE sls_price
END AS sls_price
FROM bronze_crm_sales_details;



-- For ERP.CUST info
TRUNCATE TABLE silver_erp_cust_az12;
INSERT INTO silver_erp_cust_az12(cid, bdate, gen)
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, CHAR_LENGTH(cid))
        ELSE cid
    END AS cid,
    CASE WHEN bdate > NOW() THEN NULL
		ELSE bdate
	END AS bdate,
    CASE 
  WHEN gen IS NULL THEN NULL
  WHEN UPPER(TRIM(gen)) LIKE 'F%' THEN 'Female'
  WHEN UPPER(TRIM(gen)) LIKE 'M%' THEN 'Male'
  ELSE 'n/a'
END AS gen
FROM bronze_erp_cust_az12;

-- For ERP.LOC info
TRUNCATE TABLE silver_erp_loc_a101;
INSERT INTO silver_erp_loc_a101 (cid, cntry)
SELECT
    REPLACE(cid, '-', '') cid,
    CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany' 
    WHEN TRIM(cntry) IN ('US', 'USA') 
    THEN 'United States' WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a' 
    ELSE TRIM(cntry)
END AS cntry
FROM bronze_erp_loc_a101;

-- For ERP.cat info
TRUNCATE TABLE silver_erp_px_cat_g1v2;
INSERT INTO silver_erp_px_cat_g1v2(id, cat, subcat, maintanance)
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze_erp_px_cat_g1v2

