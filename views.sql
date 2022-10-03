--- v_orders
CREATE OR REPLACE VIEW analysis.v_orders
AS SELECT 
	order_id,
	order_ts,
	user_id,
	bonus_payment,
	payment,
	"cost",
	bonus_grant,
	status
FROM production.orders;

--- v_orderstatuses
CREATE OR REPLACE VIEW analysis.v_orderstatuses
AS SELECT 
	id,
	"key"
FROM production.orderstatuses;

--- v_orderitems
CREATE OR REPLACE VIEW analysis.v_orderitems
AS SELECT 
	id,
	product_id,
	order_id,
	"name",
	price,
	discount,
	quantity
FROM production.orderitems;

--- v_orderstatuslog
CREATE OR REPLACE VIEW analysis.v_orderstatuslog
AS SELECT 
	id,
	order_id,
	status_id,
	dttm
FROM production.orderstatuslog;

--- v_products
CREATE OR REPLACE VIEW analysis.v_products
AS SELECT 
	id,
	"name",
	price
FROM production.products;

--- v_users
CREATE OR REPLACE VIEW analysis.v_users
AS SELECT 
	id,
	"name",
	login
FROM production.users;