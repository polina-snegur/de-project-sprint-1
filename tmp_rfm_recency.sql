DROP TABLE IF EXISTS analysis.tmp_rfm_recency;

CREATE TABLE analysis.tmp_rfm_recency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);

INSERT INTO analysis.tmp_rfm_recency (user_id, recency)
SELECT 
    u.id AS user_id,
    NTILE(5) OVER (ORDER BY ROUND((extract(epoch FROM (SELECT MAX(order_ts) FROM analysis.v_orders) - MAX(order_ts)) / 86400)::NUMERIC, 0) DESC) AS recency
FROM 
    analysis.v_users AS u
LEFT JOIN
    analysis.v_orders AS o 
        ON u.id = o.user_id
        AND o.status = (SELECT id FROM analysis.v_orderstatuses WHERE key = 'Closed')
        AND EXTRACT (YEAR FROM o.order_ts) >= 2022
WHERE o.order_id IS NOT NULL
GROUP BY u.id
;