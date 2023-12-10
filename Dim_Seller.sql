------------------------------------------------------
-------------------OLAP TABLES-------------------------


------------------------------------------------------
--------------------Dim_Seller------------------------
SELECT 
seller_id,
seller_zip_code_prefix,
geolocation_city as city,
latitude,
longitude,
geolocation_state as state
INTO
Olist_DW..Dim_Seller
FROM Olist_DB..olist_sellers_dataset s
INNER JOIN Olist_DB..Geolocation l
ON geolocation_zip_code_prefix = seller_zip_code_prefix
WHERE 1=2


-- surrogate key
ALTER TABLE Dim_Seller ADD  seller_key int not null identity(1,1) Primary Key

-- SDC
ALTER TABLE Dim_Seller ADD  
start_date datetime not null DEFAULT (getdate()),
end_date datetime,
Is_current tinyint DEFAULT(1)