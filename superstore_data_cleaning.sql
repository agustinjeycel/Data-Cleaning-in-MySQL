-- Data Cleaning

-- raw data
SELECT * 
FROM superstore;

-- Create Duplicate Table for Staging
-- Remove Duplicates
-- Standardize the Data (trim spaces, consistent spellings, numeric values, date logic)
-- Check Null Values or blank values
-- Remove Any Columns (any irrelevants)


CREATE TABLE superstore_cleaning
LIKE superstore;

SELECT * 
FROM superstore_cleaning;

INSERT superstore_cleaning
SELECT *
FROM superstore;

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
    FROM superstore_cleaning
)

SELECT *
FROM duplicate_rows
WHERE rn > 1;

-- Double check if that row is really a duplicate
SELECT *
FROM superstore_cleaning
WHERE `Customer Name` = 'Laurel Beltran';

-- Before Deleting, run this to turn safe mode off
SET SQL_SAFE_UPDATES = 0;

-- DELETE the duplicates
DELETE FROM superstore_cleaning
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
        FROM superstore_cleaning
    ) x
    WHERE rn > 1
);

-- After delete query, you can turn safe mode back on:
SET SQL_SAFE_UPDATES = 1;

---- DELETING DUPLICATES DONE! ----

-- Standardize the Data (trim spaces, consistent spellings, numeric values, date logic)
SELECT DISTINCT (`Ship Date`)
FROM superstore_cleaning
ORDER BY `Ship Date`; -- (do with other columns too, to check the column by ascending order)

SELECT *
FROM superstore_cleaning;
				    
-- check data type
DESCRIBE superstore_cleaning;

-- to change anything, turn safe mode off
SET SQL_SAFE_UPDATES = 0;

-- Date Logic (Convert the TEXT into Real Dates)
UPDATE superstore_cleaning
SET `Order Date` =
STR_TO_DATE(`Order Date`, '%m/%d/%Y');

UPDATE superstore_cleaning
SET `Ship Date` =
STR_TO_DATE(`Ship Date`, '%m/%d/%Y');

-- Verify the Conversion
SELECT `Order Date`, `Ship Date`
FROM superstore_cleaning
LIMIT 10;

-- Change the Column Type to DATE
ALTER TABLE superstore_cleaning
MODIFY COLUMN `Order Date` DATE;

ALTER TABLE superstore_cleaning
MODIFY COLUMN `Ship Date` DATE;

-- Confirm the New Data Types
DESCRIBE superstore_cleaning;

-- Test That Dates Work Properly
SELECT
    YEAR(`Order Date`) AS order_year,
    COUNT(*) AS total_orders
FROM superstore_cleaning
GROUP BY YEAR(`Order Date`);

-- Remove Extra Spaces (Very Important)
UPDATE superstore_cleaning
SET Profit = TRIM(Profit); -- (do with other columns too)

SELECT *
FROM superstore_cleaning;

-- Check each columns if they're standardized
SELECT DISTINCT (`Product Name`)
FROM superstore_cleaning
ORDER BY `Product Name`;

-- Check for NULL / Missing Values
SELECT *
FROM superstore_cleaning
WHERE
    `Order ID` IS NULL
    OR Sales IS NULL;
    
SELECT
    SUM(CASE WHEN `Customer Name` IS NULL THEN 1 ELSE 0 END) AS missing_customer_name
FROM superstore_cleaning;

-- Check for Negative or Impossible Values
SELECT *
FROM superstore_cleaning
WHERE Sales < 0;

SELECT *
FROM superstore_cleaning
WHERE Quantity <= 0;

SELECT *
FROM superstore_cleaning
WHERE Discount < 0
   OR Discount > 1;

-- Standardize IDs
UPDATE superstore_cleaning
SET `Product ID` = TRIM(`Product ID`);

-- Check Date Logic. Ship Date should not be before Order Date.
SELECT *
FROM superstore_cleaning
WHERE `Ship Date` < `Order Date`;

-- Check uniqueness pattern; explore highest to lowest orders (counts how many times each Order ID appears in the table, then sorts them from highest to lowest count)
SELECT `Order ID`, COUNT(*) AS total_rows
FROM superstore_cleaning
GROUP BY `Order ID`
ORDER BY total_rows DESC;

-- Check Duplicate IDs (checking potential duplicates, identifying repeated IDs only)
SELECT `Order ID`, COUNT(*)
FROM superstore_cleaning
GROUP BY `Order ID`
HAVING COUNT(*) > 1;

-- Check if duplicates are caused by multiple products (do this with every duplicate(more than one) ids)
SELECT *
FROM superstore_cleaning
WHERE `Order ID` = 'CA-2016-129714'; -- duplicates are normal, contains multiple products

-- How to Confirm If It's VALID (BEST CHECK)
SELECT `Order ID`,
       COUNT(DISTINCT `Product ID`) AS unique_products
FROM superstore_cleaning
GROUP BY `Order ID`;

-- When It IS a REAL Problem
SELECT `Order ID`, `Product ID`, COUNT(*)
FROM superstore_cleaning
GROUP BY `Order ID`, `Product ID`
HAVING COUNT(*) > 1;

-- How to confirm it is a TRUE duplicate (do it with every both id result of the last query)
SELECT *
FROM superstore_cleaning
WHERE `Order ID` = 'CA-2016-140571'
  AND `Product ID` = 'OFF-PA-10001954';  -- replace with the other Product ID

-- Key test (MOST IMPORTANT) (Show me rows that are completely identical in Order ID, Product ID, Sales, Quantity, and Profit, and tell me how many times they repeat)
SELECT `Order ID`, `Product ID`, `Sales`, `Quantity`, `Profit`, COUNT(*)
FROM superstore_cleaning
GROUP BY `Order ID`, `Product ID`, `Sales`, `Quantity`, `Profit`
HAVING COUNT(*) > 1; -- (Result: No identical copies of rows exist. The dataset has no true duplicates.)


-- See all products inside that order id, customer, location, sales, profit, etc., sorted neatly by product
SELECT *
FROM superstore_cleaning
WHERE `Order ID` = 'CA-2016-129714'
ORDER BY `Product ID`;

SELECT *
FROM superstore_cleaning;

-- Standardize Numeric Precision
UPDATE superstore_cleaning
SET Sales = ROUND(Sales, 2);

-- rename multiple columns in one ALTER TABLE query by adding multiple CHANGE COLUMN statements separated by commas. (Optional but Professional)
ALTER TABLE superstore_cleaning
CHANGE COLUMN `Row ID` row_id INT,
CHANGE COLUMN `Order ID` order_id TEXT,
CHANGE COLUMN `Order Date` order_date DATE,
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
FROM superstore_cleaning;

---- STANDARDIZING DONE! ----                 
                    
 -- Check Null Values or blank values                 
                    
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
FROM superstore_cleaning;

SELECT *
FROM superstore_cleaning;
                    
-- Check inconsistent strings (do this every columns)
SELECT DISTINCT customer_name
FROM superstore_cleaning
ORDER BY customer_name;

-- you can compare with the orig data to confirm accuracies
SELECT DISTINCT `Customer Name`
FROM superstore
ORDER BY `Customer Name`;

SELECT *
FROM superstore_cleaning
WHERE customer_name = 'Barry Franz';

SELECT *
FROM superstore_cleaning
WHERE customer_name = 'Barry Französisch';


-- SAFE manual method to CAPITALIZE each WORDS
UPDATE superstore_cleaning
SET customer_name = CONCAT_WS(' ',
    CONCAT(
        UPPER(LEFT(SUBSTRING_INDEX(customer_name, ' ', 1), 1)),
        LOWER(SUBSTRING(SUBSTRING_INDEX(customer_name, ' ', 1), 2))
    ),
    CONCAT(
        UPPER(LEFT(SUBSTRING_INDEX(customer_name, ' ', -1), 1)),
        LOWER(SUBSTRING(SUBSTRING_INDEX(customer_name, ' ', -1), 2))
    )
);


-- Check for fake or not realistic names
SELECT customer_name, COUNT(*)
FROM superstore_cleaning
WHERE customer_name = 'Sample A'
GROUP BY customer_name;

SELECT *
FROM superstore_cleaning
WHERE customer_name = 'Sample A';

-- Verify row uniqueness (If both numbers match, row_id is fully unique)
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT row_id) AS unique_row_ids
FROM superstore_cleaning;

-- Remove irrelevant columns (if only one country & row id cuz it has no analytical value)
ALTER TABLE superstore_cleaning
DROP COLUMN row_id,
DROP COLUMN country;

-- Final Inspection
SELECT *
FROM superstore_cleaning;

-- DATA CLEANING DONE!!!

                    
                    
                   