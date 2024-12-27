CREATE TABLE goldusers_signup(userid integer,gold_signup_date date); 
INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'09-22-2017'),
(3,'04-21-2017');

CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'09-02-2014'),
(2,'01-15-2015'),
(3,'04-11-2014');

CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'04-19-2017',2),
(3,'12-18-2019',1),
(2,'07-20-2020',3),
(1,'10-23-2019',2),
(1,'03-19-2018',3),
(3,'12-20-2016',2),
(1,'11-09-2016',1),
(1,'05-20-2016',3),
(2,'09-24-2017',1),
(1,'03-11-2017',2),
(1,'03-11-2016',1),
(3,'11-10-2016',1),
(3,'12-07-2017',2),
(3,'12-15-2016',2),
(2,'11-08-2017',2),
(2,'09-10-2018',3);

CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

1 what is the total amount each customer spent on zomato?
Select a.userid, SUM(b.price) total_amt_spent from sales a inner join product b on a.product_id = b.product_id
group by a.userid

2 how many days has each customer visited zomato

Select userid, COUNT(DISTINCT created_date) distinct_days from sales group by userid

3 what was the first product purchased by each customer?

Select * from
	( select *, rank() over(partition by userid order by created_date ) rnk from sales) a where rnk = 1

4 What is the most purchased item on the menu and how many times was it purchased by all customer?

Select userid, count(product_id) cnt from sales where product_id =
	(Select Top 1 product_id from Sales group by product_id order by COUNT(product_id) desc)
Group by userid

5 Which item was the most popular for the each customer?

Select * from	
	(Select *,rank() over(partition by userid order by cnt desc) rnk from
	(Select userid, product_id, count(product_id) cnt from sales group by userid, product_id)a)b
	where rnk = 1

select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

6 Which item was purchased first by the customer after they became a member?

select * from 
(select c.*, rank() over(partition by userid order by created_date ) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a 
inner join goldusers_signup b on a.userid=b.userid and created_date>=gold_signup_date) c) d where rnk=1;

7 which item was purchased just before the customer become a member?

select * from 
(select c.*, rank() over(partition by userid order by created_date desc) rnk from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a 
inner join goldusers_signup b on a.userid=b.userid and created_date<=gold_signup_date) c) d where rnk=1;

8 What is the total orders and amount spent for each member before they became a member?

Select userid, count (created_date) order_purchased, sum(price) total_amt_spent from
(select c.*,d.price from
(select a.userid,a.created_date,a.product_id,b.gold_signup_date from sales a 
inner join goldusers_signup b on a.userid=b.userid and created_date<=gold_signup_date)c inner join product d on c.product_id=d.product_id)e
group by userid

9 if buying each product generates points for eg 5rs=2 zomato point each product has different purchasing points for 
eg p1 5rs=1 zomato point, for p2=5 zomato point and p3 5rs=1 zomato point, 
calculate points collected by each customer and for which product most points have been given till now?

SELECT userid, SUM(total_points) * 2.5 AS total_money_earned
FROM (
    SELECT e.*, amt / points AS total_points
    FROM (
        SELECT d.*, 
               CASE 
                   WHEN product_id = 1 THEN 5 
                   WHEN product_id = 2 THEN 2 
                   WHEN product_id = 3 THEN 5 
                   ELSE 0 
               END AS points
        FROM (
            SELECT c.userid, c.product_id, SUM(price) AS amt
            FROM (
                SELECT a.*, b.price 
                FROM sales a 
                INNER JOIN product b ON a.product_id = b.product_id
            ) c
            GROUP BY userid, product_id
        ) d
    ) e
) f
GROUP BY userid;

SELECT * 
FROM (
    SELECT *, RANK() OVER (ORDER BY total_point_earned DESC) AS rnk
    FROM (
        SELECT product_id, SUM(total_points) AS total_point_earned
        FROM (
            SELECT e.*, amt / points AS total_points
            FROM (
                SELECT d.*, 
                       CASE 
                           WHEN product_id = 1 THEN 5 
                           WHEN product_id = 2 THEN 2 
                           WHEN product_id = 3 THEN 5 
                           ELSE 0 
                       END AS points
                FROM (
                    SELECT c.userid, c.product_id, SUM(price) AS amt
                    FROM (
                        SELECT a.*, b.price 
                        FROM sales a 
                        INNER JOIN product b ON a.product_id = b.product_id
                    ) c
                    GROUP BY userid, product_id
                ) d
            ) e
        ) f
        GROUP BY product_id
    ) g
) h
WHERE rnk = 1;


10 In the first one year after a customer joins the gold program (including their join date), 
irrespective of what the customer has purchased, they earn 5 Zomato points for every 10 Rs spent. 
Who earned more, user 1 or user 3, and what was their points earnings in their first year?

1 zomato point = 2rs

SELECT 
    c.*, 
    d.price * 0.5 AS total_points_earned
FROM 
    (
        SELECT 
            a.userid, 
            a.created_date, 
            a.product_id, 
            b.gold_signup_date
        FROM 
            sales a
        INNER JOIN 
            goldusers_signup b 
            ON a.userid = b.userid 
            AND a.created_date >= b.gold_signup_date 
            AND a.created_date <= DATEADD(YEAR, 1, b.gold_signup_date)
    ) c
INNER JOIN 
    product d 
    ON c.product_id = d.product_id;

11 rnk all the transaction of the customer

Select *, rank() over(partition by userid order by created_date) rnk From sales;

12 rank all the transaction for each member whenever they are a zomato gold member for every non gold member transaction mark as na

SELECT 
    e.*, 
    CASE WHEN rnk = 0 THEN 'na' ELSE rnk END AS rnkk
FROM 
    (
        SELECT 
            c.*, 
            CAST(
                CASE 
                    WHEN gold_signup_date IS NULL THEN 0 
                    ELSE RANK() OVER (PARTITION BY userid ORDER BY created_date DESC) 
                END AS VARCHAR
            ) AS rnk
        FROM 
            (
                SELECT 
                    a.userid, 
                    a.created_date, 
                    a.product_id, 
                    b.gold_signup_date
                FROM 
                    sales a
                LEFT JOIN 
                    goldusers_signup b 
                    ON a.userid = b.userid 
                    AND a.created_date > b.gold_signup_date
            ) c
    ) e;

