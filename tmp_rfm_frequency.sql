CREATE TABLE analysis.tmp_rfm_frequency (
 user_id INT NOT NULL PRIMARY KEY,
 frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);

INSERT INTO analysis.tmp_rfm_frequency (user_id, frequency)
SELECT *
FROM (
WITH cte AS (
    SELECT user_id,
	       COUNT(order_id) AS qty_orders
	FROM analysis.v_orders
	WHERE status = 4 -- Closed
      AND EXTRACT(YEAR FROM order_ts) >= 2022
	GROUP BY user_id
)
SELECT 
    user_id,
    CASE
		WHEN qty_orders < 4 THEN 1
		WHEN qty_orders = 4 THEN 2
		WHEN qty_orders = 5 THEN 3
		WHEN qty_orders >= 6 AND qty_orders < 8 THEN 4
		WHEN qty_orders >= 8 THEN 5
		END AS frequency
FROM cte
ORDER BY 1
) t;