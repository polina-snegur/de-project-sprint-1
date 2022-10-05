DROP TABLE IF EXISTS analysis.tmp_rfm_frequency;

CREATE TABLE analysis.tmp_rfm_frequency (
 user_id INT NOT NULL PRIMARY KEY,
 frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);

INSERT INTO analysis.tmp_rfm_frequency (user_id, frequency)
SELECT 
    u.id AS user_id,
    NTILE(5) OVER (ORDER BY COUNT(o.order_id)) AS frequency
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