-- Q4. How many customers come back? -- 
                                           -- 2,997 of 96,096 = 3.12%. -- 
WITH c AS (
	SELECT
		cu.customer_unique_id,
		count( DISTINCT o.order_id) n 
	FROM orders o 
	JOIN customers cu USING (customer_id)
	GROUP BY 1 
) 
 
 SELECT
	count(*) customers,
	sum(n>1) repeat_customers,
	ROUND (100.0 * sum(n>1) / count(*), 2) repeat_pct 
 FROM c; 





-- Q5. Which states bring the most revenue? --- 
                                               -- Three states (SP, RJ, MG) make 62.6% of revenue.
                                               -- SP brings 37.47% with 5.998M value 
SELECT 
	cu.customer_state,
    COUNT( DISTINCT cu.customer_unique_id) AS customers,
    CONCAT(ROUND(SUM(p.payment_value) / 1000000, 3), "M") AS Revenue,
    ROUND
		(100.0* SUM(p.payment_value) / 
		(SELECT SUM(payment_value) FROM payments),
		2
	)AS PCT
FROM payments p 
JOIN orders o USING (order_id) 
JOIN customers cu USING (customer_id) 
GROUP BY 1
ORDER BY 3 DESC 
LIMIT 5;
