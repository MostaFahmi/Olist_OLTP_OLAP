------------------------------------------------------
-------------------DATA WAREHOUSE TABLES-------------------------


------------------------------------------------------
--------------------Dim_Products----------------------

SELECT 
product_id,
product_category_name_english as product_name,
product_length_cm,
product_height_cm,
product_width_cm
product_weight_g
INTO Dim_Product
FROM Olist_DB..olist_products_dataset pro
JOIN Olist_DB..product_category_name_translation protr
ON pro.product_category_name = protr.product_category_name
WHERE 1=2

-- Add surrogate key 
ALTER TABLE Dim_Product ADD product_key int identity(1,1) Primary Key
