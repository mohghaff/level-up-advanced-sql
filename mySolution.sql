-- Table names:
-- employee;
-- customer;
-- model;
-- inventory;
-- sales;

SELECT * FROM employee
-- Finding Employees and their respective manager's name
SELECT e1.firstName, e1.lastName, e2.firstName as "manager's name",
e2.lastName as "manager's lastName"
FROM employee e1
JOIN employee e2
ON e1.managerId = e2.employeeId


-- Finding salespeople with zero sale

SELECT e.employeeId, e.firstName|| ' ' || e.lastName as fullName
FROM employee e
LEFT JOIN sales s
ON s.employeeId = e.employeeId
WHERE e.title = 'Sales Person'
AND s.salesId is NULL


/* Getting a list of all sales and customers data
 even if some of the data has been removed  */


 SELECT * 
 FROM sales s
 FULL OUTER JOIN customer c
 ON c.customerId = s.customerId

 -- Finding the total number of cars sold by each employee

SELECT employeeId, count(*)
FROM sales
GROUP BY employeeId
ORDER BY employeeId

-- Finding employees who have sold more than 10 cars

WITH carCount (employeeId, car_count) AS 
(SELECT employeeId, count(*) 
FROM sales
GROUP BY sales.employeeId)

SELECT e.firstName || ' ' || e.lastName as FullName, e.employeeId,
c.car_count
FROM employee e
JOIN carCount c
ON e.employeeId = c.employeeId
WHERE c.car_count > 10;

-- finding the least and most expensive cars sold by each employee


SELECT e.employeeId, e.firstName, e.lastName,
 min(s.salesAmount) as leastExpensive, max(s.salesAmount) as mostExpensive
FROM employee e
JOIN sales s
ON e.employeeId = s.employeeId
GROUP BY e.employeeId, e.firstName, e.lastName
ORDER BY e.employeeId



-- list of employees with more than 5 sales this year

SELECT e.firstName, e.lastName, e.employeeId, count(s.employeeId) as CarsSold
FROM employee e
JOIN sales s
ON e.employeeId = s.employeeId
WHERE s.soldDate >= DATE('now', 'start of year') 
GROUP BY e.firstName, e.lastName, e.employeeId
HAVING count(s.employeeId) > 5


-- Finding total sales per year rounded to 2 decimals
WITH year (yr, ct) AS
(SELECT strftime('%Y', soldDate) AS salesYear, COUNT(soldDate)  
FROM sales
GROUP BY salesYear)

SELECT round(sum(s.salesAmount),2) as totalSale, y.yr 
FROM sales s
JOIN year y 
ON strftime('%Y', s.soldDate) = y.yr
GROUP BY y.yr 

-- Finding the amount of sale per month for each employee in 2021

SELECT employeeId, 
strftime('%m', soldDate) as month,
SUM(salesAmount) as totalSales
FROM sales
WHERE strftime('%Y', soldDate) = '2021'
GROUP BY month, employeeId
ORDER BY employeeId;

-- Finding all sales where the car was electric
SELECT s.salesId
FROM sales s
JOIN inventory i 
ON s.inventoryId = i.inventoryId
JOIN model m
ON m.modelId = i.modelId
WHERE m.EngineType = 'Electric'


SELECT s.salesId
FROM sales s
JOIN inventory i 
ON s.inventoryId = i.inventoryId
WHERE i.modelId IN
(SELECT modelId
FROM model
WHERE EngineType = 'Electric')

-- finding the list of sales people and ranking the cars they've sold the most
SELECT * FROM model

SELECT e.employeeId, e.firstName, e.lastName, m.model,
RANK() OVER(PARTITION BY e.employeeId ORDER BY count(m.modelId) DESC) AS models
FROM employee e
JOIN sales s 
ON s.employeeId = e.employeeId
JOIN inventory i 
ON s.inventoryId = i.inventoryId
JOIN model m
ON m.modelId = i.modelId
GROUP BY e.employeeId, e.firstName, e.lastName, m.model


-- Finding total sales per month and annual running total

WITH MonthlySales AS (
SELECT
strftime('%m', soldDate) as month,
strftime('%Y', soldDate) as year,
ROUND(SUM(salesAmount), 2) as monthlySales
FROM sales
GROUP BY year, month
)

SELECT
month,
year,
monthlySales,
SUM(monthlySales) OVER (PARTITION BY year ORDER BY year, month) as annualRunningTotal
FROM MonthlySales
ORDER BY year, month;

