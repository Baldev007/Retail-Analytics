CREATE DATABASE IF NOT EXISTS RetailAnalysis;
-- 1. Data Cleaning( Renaming Tables, Renaming columns which are of special characters)
ALTER TABLE `customer_profiles-1-1714027410` 
RENAME To Customer_Profile;

ALTER TABLE `product_inventory-1-1714027438`
RENAME To Product_Inventory;

ALTER TABLE `sales_transaction-1714027462`
RENAME TO Sales_Transaction;

ALTER TABLE sales_transaction
RENAME Column ï»¿TransactionID to TransactionID;

ALTER TABLE product_inventory
RENAME Column ï»¿ProductID TO ProductID;

ALTER TABLE customer_profile
RENAME Column ï»¿CustomerID To CustomerID;

Describe Customer_Profile;
Describe Product_inventory;
Describe Sales_Transaction;

-- 2. Identifying the Duplicate data in Sales_Transaction Table. 
SELECT 
	TransactionID,
    Count(*)
FROM sales_transaction

Group By TransactionID
Having Count(*)>1;

-- 3. Creating a New Table from the existing Table 
CREATE TABLE Sales_Transaction_Distinct As 
SELECT * From Sales_Transaction
;

DROP TABLE sales_transaction;
ALTER TABLE sales_transaction_Distinct TO Sales_Transaction; 
    
Drop Table Sales_transaction_distinct;

-- Changing the Date columns to Date as these date columns are in text

Update Customer_Profile
Set JoinDate = STR_TO_DATE(JoinDate,"%d/%m/%y");

Update Sales_Transaction
Set TransactionDate = STR_TO_DATE(TransactionDate,"%d/%m/%y");

-- 4. identify the discrepancies in the price of the same product in "sales_transaction" and "product_inventory" tables

SELECT 
	P.ProductId,
    P.Price as Inventory_Price,
    S.Price as Sales_Price
FROM Product_inventory P
JOIN Sales_Transaction S
On P.ProductId = S.ProductId 
where p.price != S.Price;

-- 5. Update those discrepancies to match the price in both the tables
UPDATE Sales_Transaction S
Set Price= ( Select P.Price From Product_Inventory P
Where S.ProductId = P.ProductId)
Where S.ProductId in 
( Select ProductId From Product_Inventory P
Where P.Price != S.Price);

-- Finding the missing values/ Null Values from the customer_profile Table 

Select 
	Count(Case When Customerid is Null or Trim(CustomerId)='' Then 1 End) As Missing_Cid,
    Count(Case When Age is Null Then 1 End) As Missing_Age,
    Count(Case When Gender is Null Or Trim(Gender)='' Then 1 End ) As Missing_Gender,
    Count(Case When Location Is Null Or Trim(Location) = '' Then 1 End) As Missing_Location,
    Count(Case When JoinDate is Null Then 1 End) as Missing_JoinDate 
From Customer_Profile;

-- Updating the Mising value with "Unknown"
Update Customer_Profile 
Set Location='Unknown'
Where Location Is Null Or Trim(Location)='';



