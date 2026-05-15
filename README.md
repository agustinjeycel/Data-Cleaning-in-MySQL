
# MySQL Data Cleaning Project


## Project Overview

This project focuses on cleaning and preparing a raw Superstore dataset using MySQL.

The goal of this project is to transform messy raw data into a clean and reliable dataset ready for analysis.


---


## Tools Used
- MySQL Workbench


---

## Dataset Information

The dataset contains:

- Customer information
- Product details
- Sales records
- Shipping information
- Profit and discount data

---

## Data Cleaning Process

### 1. Created a Staging Table
A staging table named 'superstore_staging' was created to clean the data safely without changing the original raw dataset.
Then the raw data was copied into the staging table.



### 2. Removed Duplicate Records
Duplicates were identified using ROW_NUMBER() and deleted after verification.
- Identified duplicate rows
- Double checked records before deletion
- Removed confirmed duplicates

This helped ensure each row represented a valid transaction.



### 3. Standardized the Data
Several cleaning and formatting steps were performed to make the dataset consistent.
- Converted text dates into real DATE format
- Removed extra spaces using TRIM()
- Fixed capitalization issues
- Standardized product IDs
- Fixed quotation mark formatting in product names
- Rounded numeric values to 2 decimal places



### 4. Converted Date Columns
The following columns were converted from TEXT to DATE:
- Order Date
- Ship Date



### 5. Checked for NULL and Missing Values
Critical columns such as sales and order IDs were validated.



### 6. Validated Data Integrity
Several validation checks were performed to ensure data quality.
- Verified shipping dates were not before order dates
- Checked for negative sales values
- Checked invalid quantities and discounts
- Investigated repeated order IDs
- Confirmed duplicate order IDs were caused by multiple products within the same order



### 7. Renamed Columns
Column names were standardized into cleaner snake_case format for better readability and professional SQL practices.



### 8. Removed Irrelevant Columns
The following columns were removed:
- row_id
- country

Reason:
- row_id had no analytical value
- country contained only one value for all rows

---

## Final Result
The dataset is now:
- Cleaned
- Standardized
- Validated
- Analysis-ready

The final cleaned table is:
- superstore_staging

---

## Project Structure
MySQL Data Cleaning Project/
│
├── data/
│   ├── raw_superstore.csv
│
├── sql/
│   └── data_cleaning.sql
│
├── README.md

---

## Skills Demonstrated
- Data Cleaning
- Safe Data Cleaning By Using a Backup Table
- SQL Querying
- Identidying Duplicates
- Handling Null and Missing Values
- Standardizing Data
- Recognizing Incorrect Data Types
- Detecting Invalid Data
- Documentation of My Data Cleaning Workflow
- Attention to Detail
- Problem Solving

---

## Conclusion

This project demonstrates the complete SQL data cleaning workflow using MySQL, from raw data preparation to final validated dataset creation.

---

## Author
Jeycel Agustin
