-- Olist_business Insight report -- 

USE olist_analysis;


-- Calculate total payment value  -- 16,008,872.12 
SELECT 
	ROUND(sum(payment_value),2) AS total_paid 
FROM payments;     


-- Product_revenue --   13,591,643.7 
SELECT 
	ROUND(sum(price),2) AS product_revenue -- (itemprice) -- 
FROM order_items; 


-- Freight --   2,251,909.54 
SELECT 
	ROUND(sum(freight_value),2) AS Freight
FROM order_items; 


-- Delivered_orders --   99,441 
SELECT   	   
	count(*)
FROM orders  
WHERE order_status = "delivered";   -- 99,441 / 96,478  --  


--  Unique customers -- '96096'
 SELECT 
	COUNT(distinct customer_unique_id ) 
FROM customers ; 


-- Average review score --   4.09 
SELECT 
	round(avg(review_score),2) 
FROM reviews;


-- REVENUE per customer  -- '166.59'
SELECT 
ROUND(sum(p.payment_value)  /  COUNT(distinct cu.customer_unique_id) , 2) AS revenue_per_customer 
FROM payments p 
JOIN orders o  ON p.order_id = o.order_id  
JOIN customers cu ON o.customer_id = cu.customer_id ; 