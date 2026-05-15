-- Data Cleaning

SELECT * 
FROM superstore;

-- Remove Duplicates
-- Standardize the Data (trim spaces, consistent spellings, numeric values, date logic)
-- Null Values or blank values (populate them)
-- Remove Any Columns (any irrelevants)


CREATE TABLE superstore_staging
LIKE superstore;

SELECT * 
FROM superstore_staging;

INSERT superstore_staging
SELECT *
FROM superstore;

SELECT * 
FROM superstore_staging;


-- Remove Duplicates Using ROW_NUMBER(). This shows which rows are duplicates
WITH duplicate_rows AS (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY
                   `Order ID`,
                   `Order Date`,
                   `Ship Date`,
                   `Ship Mode`,
                   `Customer ID`,
                   `Customer Name`,
                   Segment,
                   Country,
                   City,
                   State,
                   `Postal Code`,
                   Region,
                   `Product ID`,
                   Category,
                   `Sub-Category`,
                   `Product Name`,
                   Sales,
                   Quantity,
                   Discount,
                   Profit
               ORDER BY `Row ID`
           ) AS rn
    FROM superstore_staging
)

SELECT *
FROM duplicate_rows
WHERE rn > 1;

-- Double check if that row is really a duplicate
SELECT *
FROM superstore_staging
WHERE `Customer Name` = 'Laurel Beltran';

-- Before Deleting, run this to turn safe mode off
SET SQL_SAFE_UPDATES = 0;

-- DELETE the duplicates
DELETE FROM superstore_staging
WHERE `Row ID` IN (

    SELECT `Row ID`
    FROM (
        SELECT `Row ID`,
               ROW_NUMBER() OVER(
                   PARTITION BY
                       `Order ID`,
                       `Order Date`,
                       `Ship Date`,
                       `Ship Mode`,
                       `Customer ID`,
                       `Customer Name`,
                       Segment,
                       Country,
                       City,
                       State,
                       `Postal Code`,
                       Region,
                       `Product ID`,
                       Category,
                       `Sub-Category`,
                       `Product Name`,
                       Sales,
                       Quantity,
                       Discount,
                       Profit
                   ORDER BY `Row ID`
               ) AS rn
        FROM superstore_staging
    ) x
    WHERE rn > 1
);

-- After delete query, you can turn safe mode back on:
SET SQL_SAFE_UPDATES = 1;

---- DELETING DUPLICATES DONE! ----

-- Standardize the Data (trim spaces, consistent spellings, numeric values, date logic)
SELECT DISTINCT (`Ship Date`)
FROM superstore_staging
ORDER BY `Ship Date`;

SELECT *
FROM superstore_staging;
				    
-- check data type
DESCRIBE superstore_staging;

-- to change anything, turn safe mode off
SET SQL_SAFE_UPDATES = 0;

-- Date Logic (Convert the TEXT into Real Dates)
UPDATE superstore_staging
SET `Order Date` =
STR_TO_DATE(`Order Date`, '%m/%d/%Y');

UPDATE superstore_staging
SET `Ship Date` =
STR_TO_DATE(`Ship Date`, '%m/%d/%Y');

-- Verify the Conversion
SELECT `Order Date`, `Ship Date`
FROM superstore_staging
LIMIT 10;

-- Change the Column Type to DATE
ALTER TABLE superstore_staging
MODIFY COLUMN `Order Date` DATE;

ALTER TABLE superstore_staging
MODIFY COLUMN `Ship Date` DATE;

-- Confirm the New Data Types
DESCRIBE superstore_staging;

-- Test That Dates Work Properly
SELECT
    YEAR(`Order Date`) AS order_year,
    COUNT(*) AS total_orders
FROM superstore_staging
GROUP BY YEAR(`Order Date`);

-- 1. Remove Extra Spaces (Very Important)
UPDATE superstore_staging
SET Profit = TRIM(Profit);

-- 2. Standardize Capitalization
UPDATE superstore_staging
SET State =
CONCAT(
    UPPER(LEFT(State,1)),
    LOWER(SUBSTRING(State,2))
);

-- Check each columns if they're standardized
SELECT DISTINCT (`Product Name`)
FROM superstore_staging
ORDER BY `Product Name`;

UPDATE superstore_staging
SET `Product Name` = REPLACE(`Product Name`, '""', '"');

-- 3. Check for NULL / Missing Values
SELECT *
FROM superstore_staging
WHERE
    `Order ID` IS NULL
    OR Sales IS NULL;
    
SELECT
    SUM(CASE WHEN `Customer Name` IS NULL THEN 1 ELSE 0 END) AS missing_customer_name
FROM superstore_staging;

-- 4. Check for Negative or Impossible Values
SELECT *
FROM superstore_staging
WHERE Sales < 0;

SELECT *
FROM superstore_staging
WHERE Quantity <= 0;

SELECT *
FROM superstore_staging
WHERE Discount < 0
   OR Discount > 1;

-- 5. Standardize IDs
UPDATE superstore_staging
SET `Product ID` = TRIM(`Product ID`);

-- 6. Check Date Logic. Ship Date should not be before Order Date.
SELECT *
FROM superstore_staging
WHERE `Ship Date` < `Order Date`;

-- 7. Check Duplicate IDs
SELECT `Order ID`, COUNT(*)
FROM superstore_staging
GROUP BY `Order ID`
HAVING COUNT(*) > 1;

-- Check if duplicates are caused by multiple products
SELECT *
FROM superstore_staging
WHERE `Order ID` = 'CA-2016-129714';

-- Check uniqueness pattern
SELECT `Order ID`, COUNT(*) AS total_rows
FROM superstore_staging
GROUP BY `Order ID`
ORDER BY total_rows DESC;

-- How to Confirm If It's VALID (BEST CHECK)
SELECT `Order ID`,
       COUNT(DISTINCT `Product ID`) AS unique_products
FROM superstore_staging
GROUP BY `Order ID`;

-- When It IS a REAL Problem
SELECT `Order ID`, `Product ID`, COUNT(*)
FROM superstore_staging
GROUP BY `Order ID`, `Product ID`
HAVING COUNT(*) > 1;

-- How to confirm it is a TRUE duplicate
SELECT *
FROM superstore_staging
WHERE `Order ID` = 'CA-2016-129714'
  AND `Product ID` = 'XXX';  -- replace with actual Product ID

-- Key test (MOST IMPORTANT)
SELECT `Order ID`, `Product ID`, `Sales`, `Quantity`, `Profit`, COUNT(*)
FROM superstore_staging
GROUP BY `Order ID`, `Product ID`, `Sales`, `Quantity`, `Profit`
HAVING COUNT(*) > 1;

SELECT *
FROM superstore_staging
WHERE `Order ID` = 'CA-2016-129714'
ORDER BY `Product ID`;

-- 8. Standardize Numeric Precision
UPDATE superstore_staging
SET Sales = ROUND(Sales, 2);

-- 9. Rename Columns (Optional but Professional)
ALTER TABLE superstore_staging
CHANGE COLUMN `Order Date` order_date DATE;

-- rename multiple columns in one ALTER TABLE query by adding multiple CHANGE COLUMN statements separated by commas.
ALTER TABLE superstore_staging
CHANGE COLUMN `Row ID` row_id INT,
CHANGE COLUMN `Order ID` order_id TEXT,
CHANGE COLUMN `Ship Date` ship_date DATE,
CHANGE COLUMN `Ship Mode` ship_mode TEXT,
CHANGE COLUMN `Customer ID` customer_id TEXT,
CHANGE COLUMN `Customer Name` customer_name TEXT,
CHANGE COLUMN `Segment` segment TEXT,
CHANGE COLUMN `Country` country TEXT,
CHANGE COLUMN `City` city TEXT,
CHANGE COLUMN `State` state TEXT,
CHANGE COLUMN `Postal Code` postal_code INT,
CHANGE COLUMN `Region` region TEXT,
CHANGE COLUMN `Product ID` product_id TEXT,
CHANGE COLUMN `Category` category TEXT,
CHANGE COLUMN `Sub-Category` sub_category TEXT,
CHANGE COLUMN `Product Name` product_name TEXT,
CHANGE COLUMN `Sales` sales DOUBLE,
CHANGE COLUMN `Quantity` quantity INT,
CHANGE COLUMN `Discount` discount DOUBLE,
CHANGE COLUMN `Profit` profit DOUBLE;

SELECT *
FROM superstore_staging;

---- STANDARDIZING DONE! ----                 
                    
 -- Null Values or blank values (populate them)                   
                    
SELECT
    SUM(CASE WHEN row_id IS NULL THEN 1 ELSE 0 END) AS row_id_nulls,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS order_date_nulls,
    SUM(CASE WHEN ship_date IS NULL THEN 1 ELSE 0 END) AS ship_date_nulls,
    SUM(CASE WHEN ship_mode IS NULL THEN 1 ELSE 0 END) AS ship_mode_nulls,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_nulls,
    SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS customer_name_nulls,
    SUM(CASE WHEN segment IS NULL THEN 1 ELSE 0 END) AS segment_nulls,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS city_nulls,
    SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS state_nulls,
    SUM(CASE WHEN postal_code IS NULL THEN 1 ELSE 0 END) AS postal_code_nulls,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS region_nulls,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS category_nulls,
    SUM(CASE WHEN sub_category IS NULL THEN 1 ELSE 0 END) AS sub_category_nulls,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS product_name_nulls,
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS sales_nulls,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS quantity_nulls,
    SUM(CASE WHEN discount IS NULL THEN 1 ELSE 0 END) AS discount_nulls,
    SUM(CASE WHEN profit IS NULL THEN 1 ELSE 0 END) AS profit_nulls
FROM superstore_staging;
                    
-- Check inconsistent categories
SELECT DISTINCT category
FROM superstore_staging
ORDER BY category;

-- Verify row uniqueness (If both numbers match, row_id is fully unique)
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT row_id) AS unique_row_ids
FROM superstore_staging;

-- Remove irrelevant columns (if only one country, row id cuz it has no analytical value)
ALTER TABLE superstore_staging
DROP COLUMN row_id,
DROP COLUMN country;

SELECT *
FROM superstore_staging;

-- DATA CLEANING DONE!!!

                    
                    
                   