INSERT INTO analysis.dm_rfm_segments (user_id, recency, frequency, monetary_value)
SELECT *
FROM ( 
	  SELECT u.user_id, r.recency, f.frequency, m.monetary_value
	  FROM (
	        SELECT DISTINCT user_id
	        FROM analysis.v_orders
	        WHERE EXTRACT(YEAR FROM order_ts) >= 2022
	          AND status = 4
	       ) u
	  LEFT JOIN analysis.tmp_rfm_recency r ON r.user_id = u.user_id
	  LEFT JOIN analysis.tmp_rfm_frequency f ON f.user_id = u.user_id
	  LEFT JOIN analysis.tmp_rfm_monetary_value m ON m.user_id = u.user_id
) t;

DROP TABLE IF EXISTS analysis.tmp_rfm_recency;
DROP TABLE IF EXISTS analysis.tmp_rfm_frequency;
DROP TABLE IF EXISTS analysis.tmp_rfm_monetary_value;

SELECT *
FROM analysis.dm_rfm_segments 
ORDER BY user_id
LIMIT 10;

user_id | recency | frequency | monetary_value

0	1	3	4
1	4	3	3
2	2	3	5
3	2	3	3
4	4	3	3
5	5	5	5
6	1	3	5
7	4	3	2
8	1	1	3
9	1	2	2