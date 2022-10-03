CREATE TABLE analysis.tmp_rfm_recency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);

INSERT INTO analysis.tmp_rfm_recency (user_id, recency)
SELECT *
FROM (
WITH cte AS (
    SELECT user_id,
           ROUND((extract(epoch FROM (SELECT MAX(order_ts) FROM analysis.v_orders) - MAX(order_ts)) / 86400)::NUMERIC, 0) AS qty_days
	FROM analysis.v_orders
	WHERE status = 4 -- Closed
      AND EXTRACT(YEAR FROM order_ts) >= 2022
	GROUP BY user_id
)
SELECT 
    user_id,
	CASE
		WHEN qty_days < 2 THEN 5
		WHEN qty_days >= 2 AND qty_days < 4 THEN 4
		WHEN qty_days >= 4 AND qty_days < 7 THEN 3
		WHEN qty_days >= 7 AND qty_days < 13 THEN 2
		WHEN qty_days >= 13 THEN 1
		END AS recency
FROM cte
ORDER BY 1
) t;
