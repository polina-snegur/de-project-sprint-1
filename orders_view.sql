--- v_orders
CREATE OR REPLACE VIEW analysis.v_orders
AS 
WITH cte AS (
  SELECT order_id, MAX(dttm) AS max_dttm
  FROM production.orderstatuslog
  GROUP BY order_id
)
SELECT 
	o.order_id,
	o.order_ts,
	o.user_id,
	o.bonus_payment,
	o.payment,
	o."cost",
	o.bonus_grant,
	oo.status_id as status
FROM production.orders o
INNER JOIN production.orderstatuslog oo ON oo.order_id = o.order_id
INNER JOIN cte c ON c.order_id = oo.order_id AND c.max_dttm = oo.dttm;