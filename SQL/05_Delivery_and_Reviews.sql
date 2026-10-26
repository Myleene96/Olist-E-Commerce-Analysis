-- Q6. How good is delivery?  -- 

									 -- Average delivery: 12.56 days. On-time rate: 91.89%. Late orders: 7,826 (8.11%).
SELECT 
	COUNT(*) AS delivered,
    round(avg(timestampdiff( SECOND, order_purchase_timestamp, order_delivered_customer_date) / 86400),2 ) AS avg_days,
    round(100.0 * sum(order_delivered_customer_date > order_estimated_delivery_date) / COUNT(*) ,2) as lat_pct,
    sum(order_delivered_customer_date > order_estimated_delivery_date) as Late_orders 
FROM ORDERS 
WHERE order_status = "delivered"
	AND order_delivered_customer_date IS NOT NULL;
    
    
    
    
    
--  07. Which state have the most late deliveries? (state with 1000+ orders )  ------- 

SELECT 
	cu.customer_state,
    count(order_id) AS Total_orders,
    round(avg(timestampdiff( SECOND, order_purchase_timestamp, order_delivered_customer_date) / 86400),2 ) AS avg_days,
    round(100.0 * sum(order_delivered_customer_date > order_estimated_delivery_date) / COUNT(*) ,2) as lat_pct
FROM orders o 
JOIN customers cu USING(customer_id)
WHERE order_status = "delivered"
	AND order_delivered_customer_date IS NOT NULL
GROUP BY 1
Having count(o.order_id) >= 1000
ORDER BY 3 DESC;





-- 08. Which categories have the worst reviews?-- 
                                               -- office_furniture 3.49, bed_bath_table 3.90, furniture_decor 3.90, computers_accessories 3.93. 
SELECT COALESCE(t.product_category_name_english, p.product_category_name) AS category,
       COUNT(*) AS items,
       ROUND(AVG(r.review_score), 2) AS avg_score,
       ROUND(100.0 * SUM(o.order_delivered_customer_date > o.order_estimated_delivery_date) / COUNT(*), 1) AS late_pct
FROM order_items oi
JOIN orders o        ON oi.order_id = o.order_id
JOIN reviews r ON oi.order_id = r.order_id
JOIN products p      ON oi.product_id = p.product_id
LEFT JOIN category_translation t ON t.product_category_name = p.product_category_name
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY category
HAVING COUNT(*) >= 500
ORDER BY avg_score ASC
LIMIT 6;