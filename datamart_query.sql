INSERT INTO analysis.dm_rfm_segments (user_id, recency, frequency, monetary_value)
SELECT *
FROM (
	  SELECT u.id AS user_id, r.recency, f.frequency, m.monetary_value
	  FROM analysis.v_users u
	  LEFT JOIN analysis.tmp_rfm_recency r ON r.user_id = u.id
	  LEFT JOIN analysis.tmp_rfm_frequency f ON f.user_id = u.id
	  LEFT JOIN analysis.tmp_rfm_monetary_value m ON m.user_id = u.id
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
1	3	3	3
2	2	3	5
3	2	3	3
4	4	3	3
5	5	5	5
6	1	3	5
7	4	2	2
8	1	2	3
9	1	3	2