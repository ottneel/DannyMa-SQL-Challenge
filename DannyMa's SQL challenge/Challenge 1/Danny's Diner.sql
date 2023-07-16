--1) What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, sum(m.price) AS Total_Amount_per_Customer
FROM sales s
INNER JOIN menu m 
ON s.product_id = m.product_id
GROUP BY s.customer_id;

--2) How many days has each customer visited the restaurant?
SELECT s.customer_id, CONCAT(COUNT(s.order_date), ' days') AS No_of_Days_Spent_at_the_restaurant
FROM sales s
GROUP BY customer_id;

--3) What was the first item from the menu purchased by each customer?
SELECT DISTINCT s.customer_id, FIRST_VALUE(m.product_name) OVER(PARTITION BY s.customer_id ORDER BY customer_id) AS first_item_ordered
FROM
	sales s
INNER JOIN 
	menu m ON s.product_id = m.product_id
GROUP BY
	s.customer_id, m.product_name;

--4) What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT  TOP 1 
	m.product_name, COUNT(s.product_id) AS No_of_times_purchased
FROM
	sales s
INNER JOIN
	menu m ON s.product_id = m.product_id
GROUP BY
	s.product_id, m.product_name
ORDER BY
	No_of_times_purchased DESC;

--5) Which item was the most popular for each customer?
WITH count_of_product AS (
    SELECT s.customer_id, m.product_name, COUNT(s.product_id) AS product_count,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) DESC) AS rn
    FROM sales s
    INNER JOIN menu m ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_count, product_name
FROM count_of_product
WHERE rn = 1;

--6) Which item was purchased first by the customer after they became a member?
WITH customer_product_rank AS (
	SELECT s.customer_id, m.product_name , RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS ranks
	FROM sales s
	INNER JOIN menu m ON s.product_id=m.product_id
	INNER JOIN members me ON s.customer_id= me.customer_id
	WHERE s.order_date >= me.join_date
	GROUP BY s.customer_id, s.order_date, m.product_name
)
SELECT customer_id, product_name
FROM customer_product_rank
WHERE ranks =1

--7) Which item was purchased just before the customer became a member?
SELECT
    s.customer_id,
    MAX(s.order_date) AS last_purchase_date,
    MAX(m.product_name) AS last_purchased_item,
    me.join_date
FROM
    sales AS s
INNER JOIN
    menu AS m ON s.product_id = m.product_id
INNER JOIN
    members AS me ON s.customer_id = me.customer_id
WHERE
    s.order_date < me.join_date
GROUP BY
    s.customer_id, me.join_date;

--8) What is the total items and amount spent for each member before they became a member?
SELECT
	s.customer_id, COUNT(s.product_id) AS total_items, CONCAT(SUM(m.price), ' $') AS amount_spent
FROM
	sales s
INNER JOIN
	menu m ON s.product_id=m.product_id
INNER JOIN
	members me ON s.customer_id=me.customer_id
WHERE
	s.order_date < me.join_date
GROUP BY s.customer_id;

--9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH customer_summary AS (
	SELECT
		s.customer_id,
		COUNT(s.product_id) AS total_items,
		SUM(m.price) AS amount_spent,
		(10 * SUM(m.price)) AS points,
		(
			SELECT CASE WHEN EXISTS (
				SELECT 1
				FROM menu
				WHERE product_id = s.product_id
				AND product_name = 'sushi'
			) THEN 2 * (10 * SUM(m.price))
			ELSE 10 * SUM(m.price)
			END
		) AS updated_points_with_sushi
	FROM
		sales s
	INNER JOIN
		menu m ON s.product_id = m.product_id
	GROUP BY
		s.customer_id, s.product_id
)
SELECT customer_id, SUM(updated_points_with_sushi) AS points_for_each_customer
FROM customer_summary
GROUP BY customer_id;
	


--10) In the first week after a customer joins the program (including their join date)
--they earn 2x points on all items, not just sushi
-- how many points do customer A and B have at the end of January?

WITH points_ctes AS (
	SELECT
		s.customer_id,
		(
			CASE WHEN me.join_date <= s.order_date AND DATEPART(WEEK, me.join_date) = DATEPART(WEEK, s.order_date)
				THEN 2 * (10 * SUM(m.price))
				ELSE (10*SUM(m.price))
			END
		) AS points_during_join_week
	FROM
		sales s
	INNER JOIN
		menu m ON s.product_id = m.product_id
	INNER JOIN
		members me ON s.customer_id = me.customer_id
	group by s.customer_id, me.join_date ,s.order_date
)
SELECT customer_id, SUM(points_during_join_week) AS summed_points
FROM points_ctes
GROUP BY customer_id;

--Bonus Questions
--Recreating the table

SELECT s.customer_id,s.order_date,m.product_name,m.price,
	(CASE WHEN me.join_date > s.order_date
		THEN 'N'
		ELSE 'Y'
	END) as member
INTO TEMP_TABLE
FROM sales s
INNER JOIN menu m ON s.product_id=m.product_id
INNER JOIN members me ON s.customer_id=me.customer_id
ORDER BY s.customer_id,s.order_date,m.product_name,m.price,member;



--Rank All The Things
SELECT *, (
	CASE WHEN member = 'Y' THEN RANK() OVER (PARTITION BY customer_id,member ORDER BY order_date)
	ELSE NULL
	END) as rankings
FROM TEMP_TABLE;