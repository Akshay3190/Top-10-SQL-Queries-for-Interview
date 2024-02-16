CREATE DATABASE query_practice_1;
USE query_practice_1;

-- Query 1-- Delete duplicate data-- Table name 'cars' --
-- PROBLEM STATEMENT - From the given CARS table, delete the records where car details are duplicated --
DROP TABLE cars;
CREATE TABLE cars ( model_id INT PRIMARY KEY, model_name VARCHAR (100), colour VARCHAR (100), brand VARCHAR (100));
INSERT INTO cars ( model_id, model_name, colour, brand ) VALUES
(1, 'Leaf', 'Black', 'Nissan'),
(2, 'Leaf', 'Black', 'Nissan'),
(3, 'Model S', 'Black', 'Tesla'),
(4, 'Model X', 'White', 'Tesla'),
(5, 'loniq 5', 'Black', 'Hyundai'),
(6, 'loniq 5', 'Black', 'Hyundai'),
(7, 'loniq 6', 'White', 'Hyundai');

SELECT * FROM cars;

SELECT DISTINCT model_name,colour,brand FROM cars;

-- Solution 1-- by identifying unique records & delteting records other than unique records.
SELECT min(model_id) FROM cars GROUP BY model_name, brand,colour;

-- Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column. 
-- To disable it SET SQL_SAFE_UPDATES = 0; before mentioning DELETE command--
SET SQL_SAFE_UPDATES = 0;
DELETE FROM cars
WHERE model_id NOT IN (SELECT * FROM 
					      (SELECT min(model_id) FROM cars GROUP BY model_name, brand) AS S);
SELECT * FROM cars;

-- Solution 2--identifying duplicated records by using subquery & ctid. Then delete the duplicate records.
-- ctid applicable for Postgre & not for MySQL-- 

-- Solution 2--identifying duplicated records by using window function row_number(). Then delete the duplicate records.
DELETE FROM cars
WHERE model_id IN ( SELECT model_id
				  FROM ( SELECT * ,
                         ROW_NUMBER() OVER (PARTITION BY model_name, brand ORDER BY model_id) as rn FROM cars ) x
				  WHERE x.rn > 1);
SELECT * FROM cars;  

#########################################################################################################################################################################   

-- Query 2-- Display highest and lowest salary-- Table name 'employee' --
-- PROBLEM STATEMENT - From the given employee table, display the highest and lowest salary corresponding to each department. Return the result corresponding to each employee record --

-- MySQL uses the AUTO_INCREMENT keyword to perform an auto-increment feature.
-- By default, the starting value for AUTO_INCREMENT is 1, and it will increment by 1 for each new record. It should be Primary Key.

DROP TABLE if exists employee;
CREATE TABLE employee (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR (100), dept VARCHAR (100), salary INT );
INSERT INTO employee( id,name,dept,salary) VALUES
( id,'Alexander','Admin',6500),
( id,'Leo','Finance',7000),
( id,'Robin','IT',2000),
( id,'Ali','IT',4000),
( id,'Maria','IT',6000),
( id,'Alice','Admin',5000),
( id,'Sebastian','HR',3000),
( id,'Emma','Finance',4000),
( id,'John','HR',4500),
( id,'Kabir','IT',8000);

SELECT * FROM employee;

-- Solution--
SELECT *,
MAX(salary) OVER (PARTITION BY dept ORDER BY salary DESC) AS highest_salary,
MIN(salary) OVER (PARTITION BY dept ORDER BY salary DESC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) AS lowest_salary
FROM employee;

-- UNBOUNDED PRECEDING means that the starting boundary is the first row in the partition AND
-- UNBOUNDED FOLLOWING means that the ending boundary is the last row in the partition --

#########################################################################################################################################################################   

-- Query 3-- Find actual distance-- Table name 'car_travels' --
-- PROBLEM STATEMENT --Find the actual distance travelled by each car corresponding to each day --

CREATE TABLE car_travels (cars VARCHAR (40), days VARCHAR (10), cumulative_distance INT);

INSERT INTO car_travels (cars, days, cumulative_distance) VALUES
('Car1', 'Day1', 50),
('Car1', 'Day2', 100),
('Car1', 'Day3', 200),
('Car2', 'Day1', 0),
('Car3', 'Day1', 0),
('Car3', 'Day2', 50),
('Car3', 'Day3', 50),
('Car3', 'Day4', 100);

SELECT * FROM car_travels;

-- Solution--
SELECT *,
cumulative_distance - LAG(cumulative_distance, 1, 0) OVER (PARTITION BY cars ORDER BY days) AS distance_travelled
FROM car_travels;

-- Here LAG(cumulative_distance, 1, 0) means we use LAG function to get previous records. 
-- LAG 1 means last record & LAG 0 means if there is no any previous record then it will fetch it as 0.

#########################################################################################################################################################################   

-- Query 4-- Input to Output -- Table name 'src' --
-- PROBLEM STATEMENT --Write a SQL query to convert the given input into the expected output as shown below --

DROP TABLE IF EXISTS src;
CREATE TABLE src (source VARCHAR (20), destination VARCHAR (20), distance INT);

INSERT INTO src (source, destination, distance) VALUES
('Bangalore', 'Hyderabad', 400),
('Hyderabad', 'Bangalore', 400),
('Mumbai', 'Delhi', 400),
('Delhi', 'Mumbai', 400),
('Chennai', 'Pune', 400),
('Pune', 'Chennai', 400);

SELECT * FROM src;

-- Solution-- We will use WITH clause (CTE- common table expression)--
SELECT *,
ROW_NUMBER () OVER () AS rn FROM src;

WITH cte AS 
     ( SELECT *,
       ROW_NUMBER () OVER () AS rn FROM src )
SELECT t1.source, t1.destination, t1.distance, t1.rn
FROM cte t1
JOIN cte t2
       ON t1.rn < t2.rn
       AND t1.source = t2.destination
       AND t1.destination = t2.source;

#########################################################################################################################################################################   

-- Query 5-- Ungroup the given input data -- Table name 'travel_items' --
-- PROBLEM STATEMENT --Ungroup the given input data. Display the result as per expected output --

DROP TABLE IF EXISTS travel_items;
CREATE TABLE travel_items (id INT AUTO_INCREMENT PRIMARY KEY, item_name VARCHAR (50), total_count INT);

INSERT INTO travel_items ( id, item_name, total_count) VALUES
( id, 'Water Bottle', 2 ),
( id, 'Tent', 1 ),
( id, 'Apple', 4 );

SELECT * FROM travel_items;

-- Solution -- We will have to ungroup the items by using RECURSIVE function

WITH RECURSIVE cte AS
      ( SELECT id, item_name, total_count, 1 AS level
        FROM travel_items
        UNION ALL
        SELECT cte.id, cte.item_name, cte.total_count - 1, level + 1 AS level
		FROM cte
        JOIN travel_items t ON t.item_name = cte.item_name AND t.id = cte.id
        WHERE cte.total_count > 1
       )
SELECT id, item_name
FROM cte
ORDER BY 1;       

#########################################################################################################################################################################   

-- Query 6-- Derive IPL macthes -- Table name 'ipl_teams' -- There are total 10 IPL teams. 
-- PROBLEM STATEMENT --1.Write an sql query such that each team play with every other team just once.--
-- PROBLEM STATEMENT --2.Write an sql query such that each team play with every other team twice. --

DROP TABLE IF EXISTS ipl_teams;
CREATE TABLE ipl_teams (team_code VARCHAR (10), team_name VARCHAR (40));

INSERT INTO ipl_teams (team_code, team_name) VALUES
('RCB', 'Royal Challengers Bangalore'),
('MI', 'Mumbai Indians'),
('CSK', 'Chennai Super Kings'),
('DC', 'Delhi Capitals'),
('RR', 'Rajasthan Royals'),
('SRH', 'Sunrisers Hyderabad'),
('PBKS', 'Punjab Kings'),
('KKR', 'Kolkata Knight Riders'),
('GT', 'Gujarat Titans'),
('LSG', 'Lucknow Super Giants');
                     
SELECT * FROM ipl_teams;   

-- Solution for 1- Write an sql query such that each team play with every other team just once.
SELECT  t.* , ROW_NUMBER () OVER (ORDER BY team_name) AS id
        FROM ipl_teams t;

WITH matches AS
      ( SELECT ROW_NUMBER () OVER (ORDER BY team_name) AS id, t.*
        FROM ipl_teams t )
SELECT team.team_name AS team, opponent.team_name AS opponent
FROM matches team
JOIN matches opponent ON team.id < opponent.id
ORDER BY team;

-- Solution for 1- Write an sql query such that each team play with every other team twice.
WITH clashes AS
      ( SELECT t.*, ROW_NUMBER() OVER ( ORDER BY team_name ) AS id
        FROM ipl_teams t )
SELECT playing_team.team_name AS playing_team, opponent_team.team_name AS opponent_team
FROM clashes playing_team
JOIN clashes opponent_team ON playing_team.id <> opponent_team.id
ORDER BY playing_team;    

#########################################################################################################################################################################   

-- Query 7-- Derive the output -- Table name 'sales_data' -- 
-- PROBLEM STATEMENT --write a query to fetch the results into a desired format.--

DROP TABLE IF EXISTS  sales_data;
CREATE TABLE sales_data ( Sales_date Date, Customer_ID VARCHAR (30), Amount VARCHAR (30));

INSERT INTO sales_data ( Sales_date, Customer_ID, Amount) VALUES
('2021-01-01', 'Cust-1', '50$'),
('2021-01-02', 'Cust-1', '50$'),
('2021-01-03', 'Cust-1', '50$'),
('2021-01-01', 'Cust-2', '100$'),
('2021-01-02', 'Cust-2', '100$'),
('2021-01-03', 'Cust-2', '100$'),
('2021-02-01', 'Cust-2', '-100$'),
('2021-02-02', 'Cust-2', '-100$'),
('2021-02-03', 'Cust-2', '-100$'),
('2021-03-01', 'Cust-3', '1$'),
('2021-04-01', 'Cust-3', '1$'),
('2021-05-01', 'Cust-3', '1$'),
('2021-06-01', 'Cust-3', '1$'),
('2021-07-01', 'Cust-3', '-1$'),
('2021-08-01', 'Cust-3', '-1$'),
('2021-09-01', 'Cust-3', '-1$'),
('2021-10-01', 'Cust-3', '-1$'),
('2021-11-01', 'Cust-3', '-1$'),
('2021-12-01', 'Cust-3', '-1$');

SELECT DATE_FORMAT('2024-02-15','%d-%b-%Y') AS Date;
SELECT * FROM sales_data;

SELECT DATE_FORMAT(Sales_date,'%d-%b-%Y') AS Sales_Date, Customer_ID,Amount FROM sales_data;

-- Solution -- We need to  use Case function as MY SQL dosent support PIVOT & CROSSTAB --.


select Customer_ID
, case when Jan_21 < 0 then '(' || (Jan_21 * -1) || ')$' else Jan_21 || '$' end as "Jan-21"
, case when Feb_21 < 0 then '(' || (Feb_21 * -1) || ')$' else Feb_21 || '$' end as "Feb-21"
, case when Mar_21 < 0 then '(' || (Mar_21 * -1) || ')$' else Mar_21 || '$' end as "Mar-21"
, case when Apr_21 < 0 then '(' || (Apr_21 * -1) || ')$' else Apr_21 || '$' end as "Apr-21"
, case when May_21 < 0 then '(' || (May_21 * -1) || ')$' else May_21 || '$' end as "May-21"
, case when Jun_21 < 0 then '(' || (Jun_21 * -1) || ')$' else Jun_21 || '$' end as "Jun-21"
, case when Jul_21 < 0 then '(' || (Jul_21 * -1) || ')$' else Jul_21 || '$' end as "Jul-21"
, case when Aug_21 < 0 then '(' || (Aug_21 * -1) || ')$' else Aug_21 || '$' end as "Aug-21"
, case when Sep_21 < 0 then '(' || (Sep_21 * -1) || ')$' else Sep_21 || '$' end as "Sep-21"
, case when Oct_21 < 0 then '(' || (Oct_21 * -1) || ')$' else Oct_21 || '$' end as "Oct-21"
, case when Nov_21 < 0 then '(' || (Nov_21 * -1) || ')$' else Nov_21 || '$' end as "Nov-21"
, case when Dec_21 < 0 then '(' || (Dec_21 * -1) || ')$' else Dec_21 || '$' end as "Dec-21"
, case when total < 0 then '(' || (total * 1) || ')$' else total || '$' end as total
from (
    select Customer_ID
    , sum(case when date_format(Sales_date,'%b-%y') = 'Jan-21' then replace(Amount,'$','') else 0 end) as Jan_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Feb-21' then replace(Amount,'$','') else 0 end) as Feb_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Mar-21' then replace(Amount,'$','') else 0 end) as Mar_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Apr-21' then replace(Amount,'$','') else 0 end) as Apr_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'May-21' then replace(Amount,'$','') else 0 end) as May_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Jun-21' then replace(Amount,'$','') else 0 end) as Jun_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Jul-21' then replace(Amount,'$','') else 0 end) as Jul_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Aug-21' then replace(Amount,'$','') else 0 end) as Aug_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Sep-21' then replace(Amount,'$','') else 0 end) as Sep_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Oct-21' then replace(Amount,'$','') else 0 end) as Oct_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Nov-21' then replace(Amount,'$','') else 0 end) as Nov_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Dec-21' then replace(Amount,'$','') else 0 end) as Dec_21
    , sum(replace(Amount,'$','')) as total
    from sales_data
    group by Customer_ID
        union
    select 'Total' as Customer_ID
    , sum(case when date_format(Sales_date,'%b-%y') = 'Jan-21' then replace(Amount,'$','') else 0 end) as Jan_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Feb-21' then replace(Amount,'$','') else 0 end) as Feb_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Mar-21' then replace(Amount,'$','') else 0 end) as Mar_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Apr-21' then replace(Amount,'$','') else 0 end) as Apr_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'May-21' then replace(Amount,'$','') else 0 end) as May_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Jun-21' then replace(Amount,'$','') else 0 end) as Jun_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Jul-21' then replace(Amount,'$','') else 0 end) as Jul_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Aug-21' then replace(Amount,'$','') else 0 end) as Aug_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Sep-21' then replace(Amount,'$','') else 0 end) as Sep_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Oct-21' then replace(Amount,'$','') else 0 end) as Oct_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Nov-21' then replace(Amount,'$','') else 0 end) as Nov_21
    , sum(case when date_format(Sales_date,'%b-%y') = 'Dec-21' then replace(Amount,'$','') else 0 end) as Dec_21
    , null as total
    from sales_data
    ) x
order by 1;

#########################################################################################################################################################################   

-- Query 8-- Find the hierarchy -- Table name 'emp_details' -- 
-- PROBLEM STATEMENT --Find the hierarchy of employees under a given manager "Asha".--

DROP TABLE IF EXISTS emp_details;
CREATE TABLE emp_details (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR (100), manager_id INT, salary INT, designation VARCHAR (100));

INSERT INTO emp_details (id, name, manager_id, salary, designation) VALUES
(id, 'Shripadh', NULL , 10000, 'CEO'),
(id, 'Satya', 5 , 1400, 'Software Engineer'),
(id, 'Jia', 5 , 500, 'Data Analyst'),
(id, 'David', 5 , 1800, 'Data Scientist'),
(id, 'Michael', 7 , 3000, 'Manager'),
(id, 'Aravind', 7 , 2400, 'Architect'),
(id, 'Asha', 1 , 4200, 'CTO'),
(id, 'Maryam', 1 , 3500, 'Manager'),
(id, 'Reshma', 8 , 2000, 'Business  Analyst'),
(id, 'Akshay', 6 , 2500, 'Java Developer');

SELECT * FROM emp_details;

-- Solution -- We need to solve it with  Recursive function. --
WITH RECURSIVE cte AS
      ( 
      SELECT * FROM emp_details
      WHERE name = 'Asha'
      UNION
      SELECT e.*
      FROM cte
      JOIN emp_details e ON e.manager_id = cte.id
      )
SELECT * FROM cte;      

#########################################################################################################################################################################   

-- Query 9-- Find difference in average sales -- Table name 'Sales_order' -- 
-- PROBLEM STATEMENT --Write a query to find the difference in average sales for each month of 2003 and 2004.--
    
DROP TABLE IF EXISTS sales_order;
CREATE TABLE sales_order 
( 
order_number INT AUTO_INCREMENT PRIMARY KEY,
quantity_ordered INT CHECK (quantity_ordered  > 0),
price_each FLOAT,
sales FLOAT,
order_date DATE,
status VARCHAR (30),
qtr_id INT,
month_id INT,
year_id INT,
product VARCHAR (30),
customer VARCHAR (30),
deal_size VARCHAR (10) CHECK (deal_size IN ('Small', 'Medium', 'Large'))
);

INSERT INTO sales_order (order_number,quantity_ordered,price_each,sales,order_date,status,qtr_id,month_id,year_id,product,customer,deal_size) VALUES
(order_number,30,95.7,2871,'2003-02-24','Shipped',1,2,2003,'S10_1678','C1','Small'),
(order_number,34,81.35,2765.9,'2003-05-07','Shipped',2,5,2003,'S10_1678','C2','Small'),
(order_number,41,94.74,3884.34,'2003-07-01','Shipped',3,7,2003,'S10_1678','C3','Medium'),
(order_number,45,83.26,3746.7,'2003-08-25','Shipped',3,8,2003,'S10_1678','C4','Medium'),
(order_number,49,100,5205.27,'2003-10-10','Shipped',4,10,2003,'S10_1678','C5','Medium'),
(order_number,36,96.66,3479.76,'2003-10-28','Shipped',4,10,2003,'S10_1678','C6','Medium'),
(order_number,41,100,4708.44,'2004-01-15','Shipped',1,1,2004,'S10_1678','C10','Medium'),
(order_number,45,92.83,4177.35,'2004-07-23','Shipped',3,7,2004,'S10_1678','C15','Medium'),
(order_number,46,94.74,4358.04,'2004-11-02','Shipped',4,11,2004,'S10_1678','C19','Medium'),
(order_number,42,100,4396.14,'2004-11-15','Shipped',4,11,2004,'S10_1678','C1','Medium'),
(order_number,41,100,7737.93,'2004-11-24','Shipped',4,11,2004,'S10_1678','C20','Large'),
(order_number,20,72.55,1451,'2004-12-17','Shipped',4,12,2004,'S10_1678','C21','Small');

SELECT * FROM sales_order;

-- Solution--
SELECT year_id, month_id, date_format(order_date,'%M') as mon, ROUND(avg(sales),4) as avg_sales_per_month
FROM sales_order s
WHERE year_id  IN (2003,2004)
GROUP BY year_id,month_id,date_format(order_date,'%M');

WITH cte AS
		(SELECT year_id, month_id, date_format(order_date,'%M') as mon, ROUND(avg(sales),4) as avg_sales_per_month
         FROM sales_order s
         WHERE year_id  IN (2003,2004)
         GROUP BY year_id,month_id,date_format(order_date,'%M'))
SELECT y03.mon, ROUND(abs(y03.avg_sales_per_month - y04.avg_sales_per_month),2) as  diff
FROM cte y03
JOIN cte y04 ON y03.mon = y04.mon
WHERE y03.year_id = 2003
AND y04.year_id = 2004
ORDER BY y03.month_id;        

-- to remove the negative value we used abs function . subtraction should be positive value.--

#########################################################################################################################################################################   

-- Query 10-- Pizza Delivery Status -- Table name 'cust_orders' -- 
-- A pizza company is taking orders from customers, and each pizza ordered is added to their database as a separate order.--
-- Each order has an associated status, "CREATED or SUBMITTED or DELIVERED'. --
-- An order's Final_ Status is calculated based on status as follows:--
-- 1. When all orders for a customer have a status of DELIVERED, that customer's order has a Final_Status of COMPLETED.--
-- 2. If a customer has some orders that are not DELIVERED and some orders that are DELIVERED, the Final_ Status is IN PROGRESS.--
-- 3. If all of a customer's orders are SUBMITTED, the Final_Status is AWAITING PROGRESS.--
-- 4. Otherwise, the Final Status is AWAITING SUBMISSION.--

-- Problem Statement --Write a query to report the customer_name and Final_Status of each customer's arder. Order the results by customer--

DROP TABLE IF EXISTS cust_orders;
CREATE TABLE cust_orders (cust_name VARCHAR (50), order_id VARCHAR (10), status VARCHAR (50));

INSERT INTO cust_orders (cust_name, order_id, status) VALUES
('John', 'J1', 'DELIVERED'),
('John', 'J2', 'DELIVERED'),
('David', 'D1', 'SUBMITTED'),
('David', 'D2', 'DELIVERED'),
('David', 'D3', 'CREATED'),
('Smith', 'S1', 'SUBMITTED'),
('Krish', 'K1', 'CREATED'),
('Krish', 'K2', 'SUBMITTED'),
('Aman', 'A1', 'CREATED'),
('Aman', 'A2', 'DELIVERED'),
('Robin', 'R1', 'CREATED'),
('Robin', 'R2', 'SUBMITTED'),
('Robin', 'R1', 'DELIVERED');

SELECT * FROM cust_orders;

-- Solution --

SELECT DISTINCT cust_name AS customer_name, 'COMPLETED' AS status
FROM cust_orders D
WHERE D.status = 'DELIVERED'
AND NOT EXISTS ( SELECT 1 FROM cust_orders d2
			     WHERE d2.cust_name = D.cust_name
                 AND d2.status IN ('SUBMITTED','CREATED'))
         UNION
SELECT DISTINCT cust_name AS customer_name, 'IN PROGRESS' AS status
FROM cust_orders D
WHERE D.status = 'DELIVERED'
AND EXISTS     ( SELECT 1 FROM cust_orders d2
			     WHERE d2.cust_name = D.cust_name
                 AND d2.status IN ('SUBMITTED','CREATED'))
         UNION
SELECT DISTINCT cust_name AS customer_name, 'AWAITING PROGRESS' AS status
FROM cust_orders D
WHERE D.status = 'SUBMITTED'
AND NOT EXISTS ( SELECT 1 FROM cust_orders d2
			     WHERE d2.cust_name = D.cust_name
                 AND d2.status IN ('DELIVERED'))
         UNION
SELECT DISTINCT cust_name AS customer_name, 'AWAITING SUBMISSION' AS status
FROM cust_orders D
WHERE D.status = 'CREATED'
AND NOT EXISTS ( SELECT 1 FROM cust_orders d2
			     WHERE d2.cust_name = D.cust_name
                 AND d2.status IN ('SUBMITTED','DELIVERED'));
                 
######################################################################### END OF THE QUERIES ################################################################################################   
                 