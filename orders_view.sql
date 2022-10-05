--- v_orders
CREATE OR REPLACE VIEW analysis.v_orders
AS 
WITH cte AS (
  SELECT order_id, MAX(dttm) AS max_dttm
  FROM production.orderstatuslog
  GROUP BY order_id
)
SELECT 
	ord.order_id,
	ord.order_ts,
	ord.user_id,
	ord.bonus_payment,
	ord.payment,
	ord."cost",
	ord.bonus_grant,
	osl.status_id as status
FROM production.orders ord
INNER JOIN production.orderstatuslog osl ON osl.order_id = ord.order_id
INNER JOIN cte c ON c.order_id = osl.order_id AND c.max_dttm = osl.dttm
;