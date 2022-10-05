DROP TABLE IF EXISTS analysis.tmp_rfm_monetary_value;

CREATE TABLE analysis.tmp_rfm_monetary_value (
 user_id INT NOT NULL PRIMARY KEY,
 monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);

INSERT INTO analysis.tmp_rfm_monetary_value (user_id, monetary_value)
SELECT 
    u.id AS user_id,
    NTILE(5) OVER (ORDER BY ROUND(SUM(o.payment),0)) AS monetary_value
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