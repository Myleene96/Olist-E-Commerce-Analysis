-- Q3. Which payment method is used most? -- 
                                               -- Credit card: 78.3% of value, with about 3.5 installments on average. 
                                               -- Boleto (bank slip): 17.9%.
											-- Voucher and debit card together: under 4%.
SELECT  
	payment_type,
    count(distinct order_id ) orders,
    round(sum(payment_value)) value,
    round(100.0 *sum(payment_value) / sum(sum(payment_value)) OVER(),1) pct,
	round(avg(payment_installments),1) avg_installments
FROM payments
GROUP BY 1
ORDER BY 3 DESC;  
