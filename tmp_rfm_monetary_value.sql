CREATE TABLE analysis.tmp_rfm_monetary_value (
 user_id INT NOT NULL PRIMARY KEY,
 monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);

INSERT INTO analysis.tmp_rfm_monetary_value (user_id, monetary_value)
SELECT *
FROM (
WITH cte AS (
    SELECT user_id,
	       ROUND(SUM(payment),0) AS payment_sum
	FROM analysis.v_orders
	WHERE status = 4 -- Closed
      AND EXTRACT(YEAR FROM order_ts) >= 2022
	GROUP BY user_id
)
SELECT 
    user_id,
	CASE
		WHEN payment_sum < 6000 THEN 1
		WHEN payment_sum >= 6000 AND payment_sum < 9000 THEN 2
		WHEN payment_sum >= 9000 AND payment_sum < 12000 THEN 3
		WHEN payment_sum >= 12000 AND payment_sum < 16000 THEN 4
		WHEN payment_sum >= 16000 THEN 5
		END AS monetary_value
FROM cte
ORDER BY 1
) t;