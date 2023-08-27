-- Danny Ma SQL Challenge 2: Pizza Runner
-- Data Wrangling


-- Creating Database and Creating the Tables in the database

--DROP DATABASE IF EXISTS pizza_runner; -- delete the database if it exists

CREATE DATABASE pizza_runner; -- creates the database

USE pizza_runner; -- sets the database as the default database


DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time DATETIME
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');


--The exclusions and extras columns will need to be cleaned up before using them.
-- changing 'null' texts to NULL marker
select * from customer_orders
update customer_orders
set exclusions =
(	case
		when exclusions = 'null' or exclusions = '' then NULL
		else exclusions
	end
);

update customer_orders
set extras = 
(
	case
		when extras = 'null' or extras = '' then NULL
		else extras
	end
);

--CHECKING THE DATATYPES OF EACH COLUMN OF EACH TABLE

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'runner_orders';

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'customer_orders';

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'pizza_names';

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'pizza_recipes';

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'pizza_toppings';

/* issues to clean from the runners_orders
1. change datatype of pickup column from varchar to datetime
2. strip km from distance and convert to int.
3. strip all string from duration and convert to int.
4. change data type of pizza_name, pizza_toppings to varchar from text
*/
--1) remove all occurances of km from distance
update runner_orders
set distance = cast(REPLACE(distance,'km','') as float)
where distance like '%km';
update runner_orders
set distance=
(
	CASE WHEN distance ='null' THEN NULL
	ELSE distance
	END
);
select * FROM runner_orders
select distinct distance from runner_orders
select distinct duration from runner_orders

--2) removing all variations of 'min' and changing to int
update runner_orders
set duration =
(
	case
		when duration like '% minutes' then CAST(replace(duration,'minutes','') as int)
		when duration like '%minutes' then CAST(replace(duration,'minutes','') as int)
		when duration like '% mins' then CAST(replace(duration,'mins','') as int)
		when duration like '%mins' then CAST(replace(duration,'mins','') as int)
		when duration like '% minute' then CAST(replace(duration,'minute','') as int)
		when duration = 'null' then NULL
	else duration
	end
);

--3) changing all NULLs in cancellations to No cancellation Made
UPDATE runner_orders
SET cancellation =
(
	CASE
		WHEN cancellation = 'null' then 'No Cancellation Made'
		When cancellation = 'No Cancellation Made' then NULL
	ELSE cancellation
	END
);

--4. CHANGE PICKUP DATATYPE TO DATETIME AND null TO NULL
UPDATE runner_orders
set pickup_time =
(
	CASE
		WHEN pickup_time = 'null' then NULL
	ELSE CAST(pickup_time as datetime)
	END
);
--CHANGING THE DATATYPE OF Topping_name in pizza_toppings to varchar
ALTER TABLE pizza_toppings
ALTER COLUMN topping_name varchar(35);

--CHANGING THE DATATYPE OF Pizza_name in pizza_name to varchar
ALTER TABLE pizza_names
ALTER COLUMN pizza_name varchar(35);

--CHANGING THE DATATYPE OF duration in runner_orders to int
ALTER TABLE runner_orders
ALTER COLUMN duration int

-- CHANGING THE DATATYPE OF pickup_time in runner_orders to datetime
ALTER TABLE runner_orders
ALTER COLUMN pickup_time datetime

--CHANGING THE DATATYPE OF distance in runner_orders to float
ALTER TABLE runner_orders
ALTER COLUMN distance float

--CHANGING THE DATATYPE OF toppins in pizza_recipes to varchar
ALTER TABLE pizza_recipes
ALTER COLUMN toppings varchar(25)


--split toppings column by , in the pizza_recipe and save in a new table called new pizza recipe
--create new pizza recipe table
SELECT pr.pizza_id, CAST(value AS INT) AS toppings
INTO new_pizza_recipe
FROM pizza_recipes as pr
CROSS APPLY STRING_SPLIT(pr.toppings, ',');


--Transaction code to rename the new_pizza_recipe as pizza_recipe
BEGIN TRANSACTION;
BEGIN TRY
    EXEC sp_rename 'pizza_recipes', 'old_pizza_recipe';
    EXEC sp_rename 'new_pizza_recipe', 'pizza_recipes';
    DROP TABLE old_pizza_recipe;
    COMMIT;
    PRINT 'Transaction committed.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK;
    PRINT 'Transaction rolled back.';
    THROW;
END CATCH;


--create a view that seperates the commas in the extra and exclusion columns on the customers orders table.
CREATE VIEW Customer_cleaned AS 
SELECT order_id, customer_id, pizza_id, order_time,
       CASE
           WHEN exclusions IS NOT NULL THEN
               CASE
                   WHEN exclusions NOT LIKE '%,%' THEN exclusions
                   ELSE new_exclusions.value
               END
           ELSE NULL
       END AS exclusions_value,
       CASE
           WHEN extras IS NOT NULL THEN
               CASE
                   WHEN extras NOT LIKE '%,%' THEN extras
                   ELSE new_extras.value
               END
           ELSE NULL
       END AS extras_value
FROM customer_orders
CROSS APPLY STRING_SPLIT(ISNULL(exclusions, ''), ',') as new_exclusions
CROSS APPLY STRING_SPLIT(ISNULL(extras, ''), ',') as new_extras;


