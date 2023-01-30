--CASE STUDY
--- BY :ZAKI ANWAR FARIZAN

--Product Sales Per Year
WITH cte1 AS (
	SELECT
		YEAR(ord.OrderDate) AS OrderYear, 
		cat.CategoryName, 
		SUM(det.UnitPrice*det.Quantity*(1-det.Discount)) OVER(PARTITION BY YEAR(ord.OrderDate),cat.CategoryName) AS Sales
	FROM dbo.Categories AS cat
	LEFT JOIN dbo.Products AS prod ON cat.CategoryID = prod.CategoryID
	INNER JOIN dbo.[Order Details] AS det ON det.ProductID = prod.ProductID
	INNER JOIN dbo.Orders AS ord ON ord.OrderID = det.OrderID
), cte2 AS (
	SELECT OrderYear, CategoryName, Sales, ROW_NUMBER() OVER(PARTITION BY OrderYear ORDER BY Sales DESC) as row_num
	FROM cte1
	GROUP BY OrderYear, CategoryName, Sales
	HAVING COUNT(DISTINCT OrderYear)=1
)
SELECT OrderYear, CategoryName, Sales
FROM cte2
WHERE row_num <= 10

--Employee Analysis
SELECT 
	o.EmployeeID, 
	e.Title,
	FirstName + ' ' + LastName as EmployeeName,
	COUNT(o.EmployeeID) AS Total
FROM dbo.Employees AS e
LEFT JOIN dbo.Orders AS o ON e.EmployeeID = o.EmployeeID
WHERE e.Title = 'Sales Representative'
GROUP BY o.EmployeeID, e.Title, FirstName + ' ' + LastName
ORDER BY 4 DESC

SELECT 
	o.EmployeeID, 
	e.Title,
	FirstName + ' ' + LastName as EmployeeName,
	SUM(det.UnitPrice*det.Quantity*(1-det.Discount)) AS Sales
FROM dbo.Employees AS e
LEFT JOIN dbo.Orders AS o ON o.EmployeeID = e.EmployeeID
LEFT JOIN dbo.[Order Details] AS det on o.OrderID = det.OrderID
WHERE e.Title = 'Sales Representative'
GROUP BY o.EmployeeID, e.Title, FirstName + ' ' + LastName
ORDER BY 4 DESC

SELECT 
	o.EmployeeID, 
	e.Title,
	FirstName + ' ' + LastName as EmployeeName,
	YEAR(o.OrderDate) AS Year,
	SUM(det.UnitPrice*det.Quantity*(1-det.Discount)) AS Sales
FROM dbo.Employees AS e
LEFT JOIN dbo.Orders AS o ON o.EmployeeID = e.EmployeeID
LEFT JOIN dbo.[Order Details] AS det on o.OrderID = det.OrderID
WHERE e.Title = 'Sales Representative'
GROUP BY o.EmployeeID, e.Title, FirstName + ' ' + LastName, YEAR(o.OrderDate)
ORDER BY 3, 4

--Shipper
SELECT ShipCountry, COUNT(OrderID) AS TotalOrder FROM dbo.Orders
GROUP BY ShipCountry
ORDER BY 2 DESC

SELECT ShipCountry, YEAR(OrderDate) AS OrderYear, COUNT(OrderID) AS TotalOrder FROM dbo.Orders
WHERE  ShipCountry IN ('Germany', 'USA','Brazil','France','UK','Venezuela','Austria','Sweden','Canada','Mexico')
GROUP BY ShipCountry, YEAR(OrderDate)
ORDER BY 1
