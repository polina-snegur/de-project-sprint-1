# Витрина RFM


## 1.1. Выясните требования к целевой витрине.

Постановка задачи выглядит достаточно абстрактно - постройте витрину. Первым делом вам необходимо выяснить у заказчика детали. Запросите недостающую информацию у заказчика в чате.

Зафиксируйте выясненные требования. Составьте документацию готовящейся витрины на основе заданных вами вопросов, добавив все необходимые детали.

-----------

Что сделать: составить витрину для RFM-классификации пользователей для компании, которая разрабатывает приложения по доставке еды. Для анализа нужно отобрать только успешно выполненные заказы (заказы со статусом Closed). Витрину нужно назвать dm_rfm_segments. Сохранить в базе данных de, а именно — в схеме analysis.

Зачем: подготовить данные для оценки клиентов, исходя из их лояльности. В дальнейшем компания-заказчик выберет клиентские категории, на которые стоит направить маркетинговые усилия.

За какой период: с начала 2022 года.

Ограничения по доступу: не указаны.

Сроки реализации: не указаны.

Обновление данных: не требуется.

Необходимая структура:

* user_id - идентификатор клиента;
* recency (число от 1 до 5) - значение фактора по последнему заказу, где 1 получат те, кто либо вообще не делал заказов, либо делал их очень давно, а 5 — те, кто заказывал относительно недавно;
* frequency (число от 1 до 5) - значение фактора по количеству заказов, где 1 получат клиенты с наименьшим количеством заказов, а 5 — с наибольшим;
* monetary_value (число от 1 до 5) - значение фактора по потраченной сумме, где 1 получат клиенты с наименьшей суммой, а 5 — с наибольшей.


## 1.2. Изучите структуру исходных данных.

Подключитесь к базе данных и изучите структуру таблиц.

Если появились вопросы по устройству источника, задайте их в чате.

Зафиксируйте, какие поля вы будете использовать для расчета витрины.

-----------

Есть доступ к шести таблицам:
* orders - в этой таблице записаны данные по заказам;
* orderstatuses - в этой таблице расшифрован статус заказа (Open, Cooking, Delivering, Closed, Cancelled);
* orderitems - в этой таблице записаны детальные данные по товарам из заказов;
* products - в этой таблице записан перечень товаров к заказу;
* clients - в этой таблице записаны клиенты;
* orderstatuslog - в этой таблице записаны логи заказов (журналирование).

Определим метрики, которые нужны для витрины, и сопоставим их с источниками:
* метрика recency будет связана со временем последнего успешно выполненного заказа клиента, данные - в таблице orders (user_id, max(order_ts) - order_ts), orderstatuses (key = ‘Closed’), где в результате присвоим значение фактора на основе полученных данных;
*  метрика frequency будет связана с количеством успешно выполненных заказов клиента, данные - в таблице orders (user_id, count(order_id)) и orderstatuses (key = ‘Closed’), где в результате присвоим значение фактора на основе полученных данных;
* метрика monetary_value будет связана с потраченной суммой по успешно выполненным заказам клиента, данные - в таблице orders (user_id, sum(payment)), orderstatuses (key = ‘Closed’), где в результате присвоим значение фактора на основе полученных данных. Расчет данной метрики будем основывать на поле payment, а не cost, так как для сегментации пользователей интересно именно реально потраченные деньги без учета скидки.


## 1.3. Проанализируйте качество данных

Изучите качество входных данных. Опишите, насколько качественные данные хранятся в источнике. Так же укажите, какие инструменты обеспечения качества данных были использованы в таблицах в схеме production.

-----------

Для соблюдения баланса между эффективностью и потраченным временем не будем исследовать и исправлять проблемы в таблицах/полях, которые не понадобятся для решения задачи. Для решения задачи необходимо проверить качество данных только в таблице orders.

Рассмотрим таблицу orders поподробнее. Для этого обратимся к DDL-скрипту:

* order_id int4 NOT NULL - уникальный идентификатор заказа (стоит ограничение на NULL-значения);
* order_ts timestamp NOT NULL - максимальное время по заказу, согласно таблице логов orderstatuslog (стоит ограничение на NULL-значения);
* user_id int4 NOT NULL - уникальный идентификатор клиента (стоит ограничение на NULL-значения);
* bonus_payment numeric(19, 5) NOT NULL DEFAULT 0 - величина скидки в денежных единицах (стоит ограничение на NULL-значения, устанавливается значение 0 по дефолту);
* payment numeric(19, 5) NOT NULL DEFAULT 0 - величина оплаты для клиента (стоит ограничение на NULL-значения, устанавливается значение 0 по дефолту);
* "cost" numeric(19, 5) NOT NULL DEFAULT 0 - стоимость заказа, сумма payment и bonus_payment (стоит ограничение на NULL-значения, устанавливается значение 0 по дефолту);
* bonus_grant numeric(19, 5) NOT NULL DEFAULT 0 - бонус, равный 1% от стоимости заказа (стоит ограничение на NULL-значения, устанавливается значение 0 по дефолту);
* status int4 NOT NULL - категория статуса заказа с расшифровкой в таблице orderstatuses (стоит ограничение на NULL-значения).

Качество данных:

- Определение дублей

Так как в таблице orders установлени первичный ключ по полю order_id, то дубликатов в таблице быть не может. После проверки общее количество записей = 10000, с количеством уникальных значений по ключу = 10000.

- Поиск пропущенных значений

Из DDL выше видно, что у каждого поля есть ограничение на запрет ввода NULL-значений. Значит, пропусков в данных таблицы orders быть не может.

- Типы и форматы данных

Типы данных корректные.
Для поля order_ts выбран верный тип данных timestamp, что позволит посчитать разницу во времени с текущей датой.
Для поля payment также установлен числовой тип данных numeric, что позволит посчитать сумму оплат по заказам клиентов.

- Ограничения, как инструмент обеспечения качества данных

Были использованы следующие типы ограничений:
 
* ограничение-проверка для поля cost (CONSTRAINT orders_check CHECK ((cost = (payment + bonus_payment))));
* ограничения NOT NULL для всех полей таблицы orders;
* ограничение по первичному ключу по столбцу order_id (CONSTRAINT orders_pkey PRIMARY KEY (order_id)).


## 1.4. Подготовьте витрину данных

Теперь, когда требования понятны, а исходные данные изучены, можно приступить к реализации.

### 1.4.1. Сделайте VIEW для таблиц из базы production.**

Вас просят при расчете витрины обращаться только к объектам из схемы analysis. Чтобы не дублировать данные (данные находятся в этой же базе), вы решаете сделать view. Таким образом, View будут находиться в схеме analysis и вычитывать данные из схемы production. 

Напишите SQL-запросы для создания пяти VIEW (по одному на каждую таблицу) и выполните их. Для проверки предоставьте код создания VIEW.

```SQL
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
```

### 1.4.2. Напишите DDL-запрос для создания витрины.**

Далее вам необходимо создать витрину. Напишите CREATE TABLE запрос и выполните его на предоставленной базе данных в схеме analysis.

```SQL
CREATE TABLE analysis.dm_rfm_segments (
	user_id int4 NOT NULL,
	recency int4 NOT NULL DEFAULT 0,
	frequency int4 NOT NULL DEFAULT 0,
	monetary_value int4 NOT NULL DEFAULT 0,
    CONSTRAINT dm_rfm_segments_pkey PRIMARY KEY (user_id)
);
```

### 1.4.3. Напишите SQL запрос для заполнения витрины

Наконец, реализуйте расчет витрины на языке SQL и заполните таблицу, созданную в предыдущем пункте.

Для решения предоставьте код запроса.

```SQL
INSERT INTO analysis.dm_rfm_segments (user_id, recency, frequency, monetary_value)
SELECT *
FROM (
WITH cte AS (
    SELECT user_id,
           ROUND((extract(epoch FROM (SELECT MAX(order_ts) FROM analysis.v_orders) - MAX(order_ts)) / 86400)::NUMERIC, 0) AS qty_days, -- for recency metric
	       COUNT(order_id) AS qty_orders, -- for frequency metric
	       ROUND(SUM(payment),0) AS payment_sum -- for monetary_value metric
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
		END AS recency,
    CASE
		WHEN qty_orders < 4 THEN 1
		WHEN qty_orders = 4 THEN 2
		WHEN qty_orders = 5 THEN 3
		WHEN qty_orders >= 6 AND qty_orders < 8 THEN 4
		WHEN qty_orders >= 8 THEN 5
		END AS frequency,
	CASE
		WHEN payment_sum < 6000 THEN 1
		WHEN payment_sum >= 6000 AND payment_sum < 9000 THEN 2
		WHEN payment_sum >= 9000 AND payment_sum < 12000 THEN 3
		WHEN payment_sum >= 12000 AND payment_sum < 16000 THEN 4
		WHEN payment_sum >= 16000 THEN 5
		END AS monetary_value
FROM cte
ORDER BY 1
) t;
```