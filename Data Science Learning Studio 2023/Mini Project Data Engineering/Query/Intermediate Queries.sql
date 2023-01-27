---QUERY AWAL
SELECT * FROM dbo.[Order Details]
SELECT * FROM dbo.Products
SELECT * FROM dbo.Orders
SELECT * FROM dbo.Customers
SELECT * FROM dbo.Shippers
SELECT * FROM dbo.Suppliers

---1 Tulis query untuk mendapatkan jumlah customer tiap bulan yang melakukan order pada tahun 1997.
SELECT MONTH(OrderDate) AS OrderMonth, COUNT(CustomerID) AS CustomerCount FROM dbo.Orders
WHERE YEAR(OrderDate) = 1997
GROUP BY MONTH(OrderDate)

---2 Tulis query untuk mendapatkan nama employee yang termasuk Sales Representative
SELECT FirstName + ' ' + LastName as EmployeeName, Title FROM dbo.Employees
WHERE Title = 'Sales Representative'

---3 Tulis query untuk mendapatkan top 5 nama produk yang quantitynya paling banyak diorder pada bulan Januari 1997
SELECT TOP(5) TabPro.ProductName, COUNT(TabPro.ProductName) AS ProductCount, MONTH(OrderDate) AS OrderMonth, YEAR(OrderDate) AS OrderYear FROM dbo.Orders AS TabOrd
INNER JOIN dbo.[Order Details] AS TabDet ON TabOrd.OrderID = TabDet.OrderID
INNER JOIN dbo.Products AS TabPro ON TabPro.ProductID = TabDet.ProductID
WHERE MONTH(OrderDate) = 1 AND YEAR(OrderDate) = 1997
GROUP BY TabPro.ProductName, MONTH(OrderDate), YEAR(OrderDate)
ORDER BY COUNT(TabPro.ProductName) DESC

---4 Tulis query untuk mendapatkan nama company yang melakukan order Chai pada bulan Juni 1997
SELECT TabCust.CompanyName, TabPro.ProductName, MONTH(TabOrd.OrderDate) AS OrderMonth, YEAR(TabOrd.OrderDate) AS OrderYear FROM dbo.Customers AS TabCust
INNER JOIN dbo.Orders AS TabOrd ON TabCust.CustomerID = TabOrd.CustomerID
INNER JOIN dbo.[Order Details] AS TabDet ON TabDet.OrderID = TabOrd.OrderID
INNER JOIN dbo.Products AS TabPro ON TabPro.ProductID = TabDet.ProductID
WHERE MONTH(TabOrd.OrderDate) = 6 AND YEAR(TabOrd.OrderDate) = 1997 AND TabPro.ProductName = 'Chai'

---5 Tulis query untuk mendapatkan jumlah OrderID yang pernah melakukan pembelian (unit_price dikali quantity) <=100, 100<x<=250, 250<x<=500, dan >500.
SELECT (SELECT COUNT(OrderID) 
		FROM dbo.[Order Details] 
		WHERE UnitPrice * Quantity *  (1-Discount) <= 100) AS '<=100',
	   (SELECT COUNT(OrderID) 
		FROM dbo.[Order Details] 
		WHERE UnitPrice * Quantity *  (1-Discount) > 100 AND UnitPrice * Quantity *  (1-Discount) <= 250) AS '100<x<=250',
	   (SELECT COUNT(OrderID) 
		FROM dbo.[Order Details] 
		WHERE UnitPrice * Quantity *  (1-Discount) > 250 AND UnitPrice * Quantity *  (1-Discount) <= 500) AS '250<x<=500',
	   (SELECT COUNT(OrderID) 
		FROM dbo.[Order Details] 
		WHERE UnitPrice * Quantity *  (1-Discount) > 500) AS '>500'

---6 Tulis query untuk mendapatkan Company name pada tabel customer yang melakukan pembelian di atas 500 pada tahun 1997
SELECT DISTINCT CompanyName  FROM dbo.Customers AS TabCust
INNER JOIN dbo.Orders AS TabOrd ON TabCust.CustomerID = TabOrd.CustomerID
INNER JOIN dbo.[Order Details] AS TabDet ON TabOrd.OrderID = TabDet.OrderID
WHERE YEAR(TabOrd.OrderDate) = 1997
GROUP BY TabCust.CompanyName, UnitPrice*Quantity *(1-Discount)
HAVING UnitPrice*Quantity*(1-Discount) > 500

---7 Tulis query untuk mendapatkan nama produk yang merupakan Top 5 sales tertinggi tiap bulan di tahun 1997.
WITH cte AS (
	SELECT 
		MONTH(ord2.OrderDate) as OrderMonth, 
		prod.ProductName as ProductName, ord1.UnitPrice * ord1.Quantity * (1-ord1.Discount) as Sales, 
		ROW_NUMBER() OVER (PARTITION BY MONTH(ord2.OrderDate) ORDER BY ord1.UnitPrice * ord1.Quantity * (1-ord1.Discount) DESC) as row_num
	FROM dbo.Products as prod
	JOIN dbo.[Order Details] as ord1 ON prod.ProductID = ord1.ProductID
	JOIN dbo.Orders as ord2 ON ord1.OrderID = ord2.OrderID
	WHERE YEAR(ord2.OrderDate) = 1997
)
SELECT OrderMonth, ProductName, Sales
FROM cte
WHERE row_num <=5

---8 Buatlah view untuk melihat Order Details yang berisi OrderID, ProductID, ProductName, UnitPrice, Quantity, Discount, Harga setelah diskon.
SELECT det.OrderID, det.ProductID, prod.ProductName, det.UnitPrice, det.Quantity, det.Discount, det.UnitPrice*(1-det.Discount) as NewUnitPrice
FROM dbo.[Order Details] AS det
JOIN dbo.Products AS prod ON det.ProductID = prod.ProductID

---9 Buatlah procedure Invoice untuk memanggil CustomerID, CustomerName/company name, OrderID, OrderDate, RequiredDate, ShippedDate jika terdapat inputan CustomerID tertentu.
SELECT ord.CustomerID, cust.CompanyName, ord.OrderID, ord.OrderDate, ord.RequiredDate, ord.ShippedDate  FROM dbo.Orders AS ord
JOIN dbo.Customers AS cust ON ord.CustomerID = cust.CustomerID