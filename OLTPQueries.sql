-------------------------------------------------
-------Exploratory & Cleaning Datasets-----------
-------------------------------------------------


-----------------Orders Table-------------------------
------------------------------------------------------
Select * 
From olist_orders_dataset




-- Standardize Date Formate
-- Modifying order_estimated_delivery_date DT

Alter Table olist_orders_dataset Alter Column order_estimated_delivery_date Date

-- Modifying: order_purchase_timestamp, order_approved_at,
-- order_delivered_carrier_date, and order_delivered_customer_date DT

Alter Table olist_orders_dataset Alter Column order_purchase_timestamp smalldatetime
go
Alter Table olist_orders_dataset Alter Column order_approved_at smalldatetime
go
Alter Table olist_orders_dataset Alter Column order_delivered_carrier_date smalldatetime
go
Alter Table olist_orders_dataset Alter Column order_delivered_customer_date smalldatetime


-- Duplication Check

SELECT*
FROM
(
SELECT order_id, COUNT(order_id) [Duplicated Order]
FROM olist_orders_dataset
GROUP BY order_id
) as temp
WHERE [Duplicated Order] > 1





---- Exploring order_status
SELECT order_status, COUNT(order_status)
FROM olist_orders_dataset
GROUP BY order_status






-- Delete ambiguous rows
-- Check and Delete ambiguous order_delivered_customer_date rows
DELETE
--SELECT order_status, order_delivered_customer_date,COUNT(order_status)
FROM olist_orders_dataset
WHERE order_delivered_customer_date is null 
AND order_status = 'delivered'






-- Check and Delete ambiguous order_delivered_carrier_date rows
--DELETE
SELECT order_status, order_delivered_carrier_date,COUNT(order_status)
FROM olist_orders_dataset
WHERE order_delivered_carrier_date is null 
AND order_status = 'shipped'
GROUP BY order_status,order_delivered_carrier_date









-------------Order_Status_Table-----------------------
------------------------------------------------------

--SELECT DISTINCT(order_status)
--FROM olist_orders_dataset

Create Table Order_Status
(
order_status_id int identity(1,1),
order_status varchar(50) Primary Key
)
GO
insert into Order_Status (order_status)
SELECT DISTINCT(Order_Status)
FROM olist_orders_dataset

--SELECT * 
--FROM Order_Status

-- Updating and Renaming the order_status field in olist_orders
UPDATE a
SET a.order_status = Order_Status_id
FROM olist_orders_dataset a
JOIN Order_Status b
ON a.order_status = b.order_status

EXEC sp_rename 'olist_orders_dataset.order_status', 'order_status_id', 'COLUMN'





-------------Order_Items_Table-----------------------
------------------------------------------------------

SELECT *
FROM olist_order_items_dataset

-- Create Summarized Table [Order_Items]

SELECT order_id, product_id, seller_id,MAX(product_counter) Qty,
shipping_limit_date,price, freight_value
INTO [Order_Items]
FROM olist_order_items_dataset
GROUP BY order_id, product_id, 
seller_id,shipping_limit_date,price, freight_value

SELECT *
FROM Order_Items
ORDER BY QTY DESC

-- Check for anomalies
SELECT AVG(price) AVG_PRICE, MAX(price) MAX_PRICE, MIN(price) MIN_PRICE,
AVG(freight_value) AVG_FREIGHT, MAX(freight_value) MAX_FREIGHT, MIN(freight_value) MIN_FRIEGHT
FROM Order_Items

-- Modifying shipping_limit_date format
ALTER TABLE Order_Items ALTER COLUMN shipping_limit_date Date

-- Check the validaty of the PKs
-- Check if every item within the order has only one seller

SELECT order_id,product_id, COUNT(distinct seller_id) seller_count
FROM Order_Items
GROUP BY order_id,product_id
ORDER BY seller_count desc


-- Check for Duplicates
WITH Order_ItemsCTE AS 
(
SELECT 
	    *,ROW_NUMBER() Over(
		 Partition by 
		 order_id,
		 product_id 
		 Order by 
		 order_id,
		 product_id) as counter
FROM Order_Items
)
SELECT * 
FROM Order_ItemsCTE
WHERE counter > 1

-- Rounding price and freight_value
Update Order_Items
SET price = ROUND(price,2), 
freight_value = ROUND(freight_value,2)


SELECT order_id, count(DISTINCT freight_value) aa
FROM Order_Items
GROUP BY order_id
Order By aa desc


-------------Order_Reviews_Table-----------------------
------------------------------------------------------

SELECT *
FROM olist_order_reviews_dataset

-- Modifying Date format

ALTER TABLE olist_order_reviews_dataset ALTER COLUMN review_creation_date Date
go
ALTER TABLE olist_order_reviews_dataset ALTER COLUMN review_answer_timestamp Date

-- Check on if the unique review could include more than one order
SELECT review_id, COUNT(distinct order_id) orders_per_review
FROM olist_order_reviews_dataset
GROUP BY review_id
ORDER BY orders_per_review DESC

-- Check on Duplication
WITH ReviewCTE AS
(
SELECT *,
		ROW_NUMBER() OVER(
		PARTITION BY
		review_id
		ORDER BY
		review_id) RN
FROM olist_order_reviews_dataset
)
DELETE 
FROM ReviewCTE
WHERE RN > 1

-- Check the anomalies

SELECT MAX(review_score), MIN(review_score)
FROM olist_order_reviews_dataset


-- Check reviews with NULL id
SELECT *
FROM olist_order_reviews_dataset
WHERE review_id IS NULL


-- Check review_creation_date cleanliness

SELECT *
FROM olist_order_reviews_dataset
WHERE 
	review_creation_date like '%[x]%'
OR	review_creation_date like '[a-z]%'
OR	review_creation_date like '%[a-z]'
OR	review_creation_date like '[^2]%'


-- Check review_answer_timestamp cleanliness

SELECT *
FROM olist_order_reviews_dataset
WHERE 
	review_answer_timestamp like '%[x]%'
OR	review_answer_timestamp like '[a-z]%'
OR	review_answer_timestamp like '%[a-z]'
OR	review_answer_timestamp like '[^2]%'


-- Renaming review_answer_timestamp
EXEC sp_rename 'olist_order_reviews_dataset.review_answer_timestamp', 'review_answer_date','COLUMN'



-----------
--- Check for reviews to orders that doesn't exist
WITH OrderNotFoundCTE AS
(
SELECT order_id
FROM olist_order_reviews_dataset
WHERE order_id  NOT IN (SELECT order_id
						 FROM olist_orders_dataset)
)
DELETE
FROM OrderNotFoundCTE






-------------Order_Payments_Table-----------------------
--------------------------------------------------------

SELECT *
FROM olist_order_payments_dataset




-- Check Duplicates
WITH PaymentsCTE AS
(
SELECT *,
		ROW_NUMBER()OVER(
		PARTITION BY
		order_id,
		payment_sequential
		ORDER BY
		order_id,
		payment_sequential) RN

FROM olist_order_payments_dataset
)
SELECT *
FROM PaymentsCTE
WHERE RN > 1





-- Summerizing Payments Table
SELECT order_id, 
MAX(payment_sequential) payment_sequential, 
MAX(payment_type_id) payment_type_id,
MAX(payment_installments) payment_installments,
MAX(payment_value) payment_value
INTO Order_Payment
FROM olist_order_payments_dataset
GROUP BY order_id




-- Check payment_type typos

SELECT DISTINCT(payment_type)
FROM olist_order_payments_dataset




-- Check the anomalies

SELECT MAX(payment_installments) max_inst, MIN(payment_installments) min_inst,
MAX(payment_value) max_value, MIN(payment_value) min_value
FROM olist_order_payments_dataset








-------------Payments_Type_Table-----------------------
-------------------------------------------------------- 


CREATE TABLE Payments_Type
(
payment_type_id int identity(1,1),
payment_type varchar(20)
)

INSERT INTO Payments_Type(payment_type)
SELECT DISTINCT(Payment_Type)
FROM olist_order_payments_dataset

SELECT *
FROM Payments_Type




-- Updating payment_type field in olist_order_payments
UPDATE a
SET a.payment_type = payment_type_id
FROM olist_order_payments_dataset a
JOIN Payments_Type b
ON a.payment_type = b.payment_type



-- Renaming payment_type in olist_order_payments

EXEC sp_rename 'olist_order_payments_dataset.payment_type', 'payment_type_id','COLUMN'




-- Rounding payment_value

UPDATE olist_order_payments_dataset
SET payment_value = ROUND(payment_value,2)





-------------Customers_Table-----------------------
---------------------------------------------------

SELECT *
FROM olist_customers_dataset

-- Check for Duplicates

SELECT customer_id, COUNT(customer_id) counter
FROM olist_customers_dataset
GROUP BY customer_id
ORDER BY counter DESC




-- Check for customer_city typos

SELECT DISTINCT(customer_city)
FROM olist_customers_dataset
ORDER BY customer_city









-------------Geolocation_Table---------------------
---------------------------------------------------
SELECT *
FROM olist_geolocation_dataset


-- Summerize the table
SELECT geolocation_zip_code_prefix,
geolocation_city,
MAX(geolocation_lat) latitude, 
MAX(geolocation_lng) longitude, 
geolocation_state
INTO Geolocation
FROM olist_geolocation_dataset
GROUP BY geolocation_zip_code_prefix, geolocation_state, geolocation_city


-- including customers and sellers locations in the Geolocation table
UPDATE Geolocation
SET geolocation_zip_code_prefix = 
ISNULL(geolocation_zip_code_prefix, ISNULL(customer_zip_code_prefix, seller_zip_code_prefix)),
geolocation_city = 
ISNULL(geolocation_city, ISNULL(customer_city, seller_city)),
geolocation_state = 
ISNULL(geolocation_state, ISNULL(customer_state, seller_state))
FROM Geolocation
FULL OUTER JOIN olist_customers_dataset
ON geolocation_zip_code_prefix = customer_zip_code_prefix
FULL OUTER JOIN olist_sellers_dataset
ON seller_zip_code_prefix =geolocation_zip_code_prefix



-- Check the nullness within the table after the update
SELECT *
FROM Geolocation
WHERE geolocation_zip_code_prefix is null
OR geolocation_city is null
OR geolocation_state is null




-- Drop zip codes duplicates

WITH GeolocationDuplicatesCTE AS
(
SELECT *,
	   Row_Number() OVER(
	   PARTITION BY 
	   geolocation_zip_code_prefix
	   ORDER BY
	   geolocation_zip_code_prefix) RN
FROM Geolocation
)
DELETE 
FROM GeolocationDuplicatesCTE
WHERE RN > 1





--- Drop location columns from Customers and Sellers Table 

ALTER TABLE olist_customers_dataset 
DROP COLUMN
customer_city,
customer_state
go
ALTER TABLE olist_sellers_dataset 
DROP COLUMN
seller_city,
seller_state






-------------Products_Table---------------------
------------------------------------------------

SELECT *
FROM olist_products_dataset

-- Remove Duplicates

WITH ProductsCTE AS
(
SELECT*,
	ROW_NUMBER() OVER(
	PARTITION BY
	product_id,
	ORDER BY 
	product_id) RN
FROM olist_products_dataset
)
SELECT *
FROM ProductsCTE
WHERE RN > 1





-------------Matching Relationships-------------
------------------------------------------------


--- MATCHING product_table with product_translation_table


INSERT INTO product_category_name_translation (product_category_name)
SELECT DISTINCT p.product_category_name
FROM olist_products_dataset as p
WHERE p.product_category_name NOT IN (SELECT product_category_name
									FROM product_category_name_translation
									)
AND p.product_category_name is not null



--- MATCHING order_items_table with orders_table

SELECT COUNT(DISTINCT a.order_id), COUNT(DISTINCT b.order_id)
FROM olist_orders_dataset a
FULL OUTER JOIN Order_Items b
ON a.order_id = b.order_id


-- Inserting what is missing in Orders_Table
INSERT INTO olist_orders_dataset(order_id)
SELECT order_id
FROM Order_Items
WHERE order_id NOT IN (SELECT order_id
					   FROM olist_orders_dataset)


-- Inserting what is missing in Geolocation_Table from sellers
INSERT INTO Geolocation(geolocation_zip_code_prefix)
SELECT DISTINCT seller_zip_code_prefix
FROM olist_sellers_dataset
WHERE seller_zip_code_prefix NOT IN (SELECT geolocation_zip_code_prefix
									FROM Geolocation)

-- Inserting what is missing in Geolocation_Table from customers
INSERT INTO Geolocation(geolocation_zip_code_prefix)
SELECT DISTINCT customer_zip_code_prefix
FROM olist_customers_dataset
WHERE customer_zip_code_prefix NOT IN (SELECT geolocation_zip_code_prefix
									FROM Geolocation)
















 



















--




