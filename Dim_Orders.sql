------------------------------------------------------
-------------------OLAP TABLES-------------------------


------------------------------------------------------
--------------------Dim_Orders------------------------


SELECT 
o.order_id, 
pt.payment_type, 
op.payment_installments,
os.order_status,
o.order_purchase_timestamp,
o.order_approved_at,
o.order_delivered_carrier_date,
o.order_delivered_customer_date,
o.order_estimated_delivery_date,
rev.review_id,
rev.review_score,
rev.review_comment_title,
rev.review_comment_message
INTO Dim_Orders
FROM Olist_DB..Order_Payment op
JOIN Olist_DB..Payments_Type pt
ON op.payment_type_id = pt.payment_type_id
JOIN Olist_DB..olist_orders_dataset o
ON o.order_id = op.order_id
JOIN Olist_DB..Order_Status os
ON os.order_status_id = o.order_status_id
JOIN Olist_DB..olist_order_reviews_dataset rev
ON rev.order_id = o.order_id
WHERE 1=2


-- Add surrogate key

ALTER TABLE Dim_Orders ADD order_key int not null  identity(1,1) Primary Key