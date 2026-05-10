/*
=============================================================================
Data Loading Script: Load Bronze Tables
=============================================================================
Script Purpose:
    This script loads raw data from CSV files into the 'Bronze Layer' tables.
    Each table is truncated (emptied) before the load to avoid duplicates.
=============================================================================
*/

-- =============================================================================
-- 1. CRM Section
-- =============================================================================

-- Loading bronze_crm_cust_info
TRUNCATE TABLE bronze_crm_cust_info; 
LOAD DATA LOCAL INFILE '/Users/weronikawawrzyczek/Desktop/sql-data-warehouse-project/datasets/source_crm/cust_info.csv'
INTO TABLE bronze_crm_cust_info
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

-- Loading bronze_crm_prd_info
TRUNCATE TABLE bronze_crm_prd_info; 
LOAD DATA LOCAL INFILE '/Users/weronikawawrzyczek/Desktop/sql-data-warehouse-project/datasets/source_crm/prd_info.csv'
INTO TABLE bronze_crm_prd_info
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

-- Loading bronze_crm_cust_info
TRUNCATE TABLE bronze_crm_cust_info; 
LOAD DATA LOCAL INFILE '/Users/weronikawawrzyczek/Desktop/sql-data-warehouse-project/datasets/source_crm/sales_details.csv'
INTO TABLE bronze_crm_sales_details
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

-- Loading bbronze_erp_cust_az12
TRUNCATE TABLE bronze_erp_cust_az12;
LOAD DATA LOCAL INFILE '/Users/weronikawawrzyczek/Desktop/sql-data-warehouse-project/datasets/source_erp/CUST_AZ12.csv'
INTO TABLE bronze_erp_cust_az12
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

-- =============================================================================
-- 2. ERP Section
-- =============================================================================

-- Loading bronze_erp_loc_a101
TRUNCATE TABLE bronze_erp_loc_a101;
LOAD DATA LOCAL INFILE '/Users/weronikawawrzyczek/Desktop/sql-data-warehouse-project/datasets/source_erp/LOC_A101.csv'
INTO TABLE bronze_erp_loc_a101
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

-- Loading bronze_erp_px_cat_g1v2
TRUNCATE TABLE bronze_erp_px_cat_g1v2;
LOAD DATA LOCAL INFILE '/Users/weronikawawrzyczek/Desktop/sql-data-warehouse-project/datasets/source_erp/PX_CAT_G1V2.csv'
INTO TABLE bronze_erp_px_cat_g1v2
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;
