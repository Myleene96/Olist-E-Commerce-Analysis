-- Business analysis --

-- Q1. How does revenue grow over time? --   grew from about 112K (Jan 2017) to about 950K (early 2018)
										-- Best month: Nov 2017 at 987,765 (+52% vs October, likely Black Friday), then it dropped 26% in December.
                                        --   Growth flattened in 2018 at about 850K to 975K per month.
		
WITH m AS(
	SELECT substr(o.order_purchase_timestamp,1,7) ym,
    SUM(oi.price) rev 
FROM orders o 
JOIN order_items oi USING (order_id)
WHERE o.order_status = "delivered"  
GROUP BY ym )
SELECT 
	ym,
    round(rev) rev,
    ROUND(100.0 * (rev - LAG (rev) OVER(ORDER BY ym)) 
    / LAG (rev) OVER(ORDER BY ym),
    1) mom_pct 
FROM m 
ORDER BY ym;



-- Q2. Which categories earn the most? --    
                                                -- health beauty 1,258,681  9.3%
                                                -- watches gifts 1,205,006 	8.9% 
                                                -- bed bath table 1,036,989  7.6%
                                                -- sports leisure  988,049 7.3%
                                                -- computers accessories  911,954  6.7%

SELECT
	t.product_category_name_english AS category,
    ROUND(sum(oi.price)) AS revenue,
    ROUND(100.0 * SUM(oi.price) / ( SELECT SUM(price) FROM order_items),1) AS pct
FROM order_items oi JOIN products p USING (product_id) 
LEFT JOIN category_translation t USING (product_category_name) 
GROUP BY category
ORDER BY revenue DESC
LIMIT 5;