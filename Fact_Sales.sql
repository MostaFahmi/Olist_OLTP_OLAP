-------------------------------------------------------
-------------------DATA WAREHOUSE TABLES-------------------------


------------------------------------------------------
--------------------Fact_Sales------------------------
DROP TABLE Fact_Sales 
CREATE TABLE Fact_Sales
(
Order_Key int,
Product_Key int,
Customer_Key nvarchar(50),
Seller_Key int,
Order_Purchase_TimestampKey INT,
Order_Approved_AtKey INT ,
Order_Delivered_Carrier_DateKey  INT,
Order_Delivered_Customer_DateKey INT,
Order_Estimated_Delivery_DateKey INT,
Shipping_Limit_DateKey INT,
Quantity INT,
Freight_Value float,
Sales_Amount Money,



Constraint Fk_fact_sales_dim_orders
foreign key (order_Key) references Dim_Orders(order_Key),

Constraint Fk_fact_sales_dim_product
foreign key (Product_Key) references Dim_Product(Product_Key),

Constraint Fk_fact_sales_dim_seller
foreign key (seller_Key) references Dim_Seller(seller_Key),

Constraint Fk_fact_sales_dim_customer
foreign key (customer_Key) references Dim_Customer(customer_id),

Constraint Fk_fact_sales_Purchase_dim_date
foreign key (Order_Purchase_TimestampKey) references Dim_Date(DateKey),

Constraint Fk_fact_sales_approved_dim_date2
foreign key (Order_Approved_AtKey) references Dim_Date(DateKey),

Constraint Fk_fact_sales_delivered_carrier_dim_date3
foreign key (Order_Delivered_Carrier_DateKey) references Dim_Date(DateKey),

Constraint Fk_fact_sales_delivered_cusomter_dim_date4
foreign key (Order_Delivered_Customer_DateKey) references Dim_Date(DateKey),

Constraint Fk_fact_sales_estimated_dim_date
foreign key (Order_Estimated_Delivery_DateKey) references Dim_Date(DateKey),

Constraint Fk_fact_sales_shipping_dim_date
foreign key (Shipping_Limit_DateKey) references Dim_Date(DateKey)

)

-- Create Index

CREATE INDEX fact_sales_dim_product
on Fact_Sales(Product_Key)

