-- 找出和最貴的產品同類別的所有產品
SELECT 
	CategoryID,ProductName
FROM products
WHERE CategoryID = 
　　(SELECT 
		CategoryID
	FROM products
	WHERE UnitPrice = 
	(SELECT 
			MAX(UnitPrice)
	　FROM products　
	)
)

-- 找出和最貴的產品同類別最便宜的產品
SELECT TOP 1
	CategoryID, ProductName, UnitPrice
FROM Products
WHERE CategoryID = (
    SELECT 
		CategoryID
    FROM Products
    WHERE UnitPrice = (
        SELECT 
			MAX(UnitPrice)
        FROM Products
    )
)
ORDER BY UnitPrice ASC;

-- 計算出上面類別最貴和最便宜的兩個產品的價差
SELECT 
    MAX(UnitPrice) - MIN(UnitPrice) AS PriceDifference
FROM Products
WHERE CategoryID = (
    SELECT 
		CategoryID
    FROM Products
    WHERE UnitPrice = (
        SELECT 
			MAX(UnitPrice)
        FROM Products
    )
)

-- 找出沒有訂過任何商品的客戶所在的城市的所有客戶
SELECT *
FROM Customers
WHERE City IN (
  SELECT City
  FROM Customers
  LEFT JOIN Orders 
  ON Customers.CustomerID = orders.CustomerID
  WHERE orders.CustomerID IS NULL
)

-- 找出第 5 貴跟第 8 便宜的產品的產品類別
SELECT 
	ProductName,UnitPrice,CategoryID
FROM Products
ORDER BY UnitPrice DESC
OFFSET 4 ROWS
FETCH NEXT 1 ROWS ONLY


SELECT 
	ProductName,UnitPrice,CategoryID
FROM Products
ORDER BY UnitPrice ASC
OFFSET 7 ROWS
FETCH NEXT 1 ROWS ONLY

-- 找出誰買過第 5 貴跟第 8 便宜的產品
SELECT 
	C.CustomerID,C.ContactName
FROM Customers c
INNER JOIN Orders o ON o.CustomerID=c.CustomerID
INNER JOIN [Order Details]od ON o.OrderID=od.OrderID
INNER JOIN Products p ON od.ProductID=p.ProductID
WHERE p.ProductID IN 
    (
        SELECT 
            ProductID
        FROM  Products
        ORDER BY UnitPrice DESC
        OFFSET 4 ROWS
        FETCH NEXT 1 ROWS ONLY 
    ) 
    OR p.ProductID IN 
    (
        SELECT 
            ProductID
        FROM Products
        ORDER BY UnitPrice ASC
        OFFSET 7 ROWS
        FETCH NEXT 1 ROWS ONLY 
    )



-- 找出誰賣過第 5 貴跟第 8 便宜的產品
SELECT
e.EmployeeID,FirstName,LastName
FROM  Employees e
INNER JOIN Orders o ON o.EmployeeID = e.EmployeeID
INNER JOIN [Order Details]od ON o.OrderID=od.OrderID
INNER JOIN Products p ON od.ProductID=p.ProductID
WHERE p.ProductID IN 
    (
        SELECT 
            ProductID
        FROM  Products
        ORDER BY UnitPrice DESC
        OFFSET 4 ROWS
        FETCH NEXT 1 ROWS ONLY 
    ) 
    OR p.ProductID IN 
    (
        SELECT 
            ProductID
        FROM Products
        ORDER BY UnitPrice ASC
        OFFSET 7 ROWS
        FETCH NEXT 1 ROWS ONLY 
    )

-- 找出 13 號星期五的訂單 (惡魔的訂單)
SELECT 
	* 
FROM Orders 
WHERE DATEPART(WEEKDAY,OrderDate) = 6 AND DATEPART(DAY,OrderDate) = 13
-- 找出誰訂了惡魔的訂單
SELECT 
	c.* 
FROM Orders o
INNER JOIN Customers c
ON o.CustomerID = c.CustomerID 
WHERE DATEPART(WEEKDAY,OrderDate) = 6 AND DATEPART(DAY,OrderDate) = 13

-- 找出惡魔的訂單裡有什麼產品
SELECT DISTINCT 
	p.*
FROM Orders 
INNER JOIN [Order Details] od  
ON orders.OrderID = od.OrderID 
INNER JOIN Products p
ON od.ProductID = p.ProductID 
WHERE DATEPART(WEEKDAY,orders.OrderDate) = 6 AND DATEPART(DAY,orders.OrderDate) = 13

-- 列出從來沒有打折 (Discount) 出售的產品
SELECT
	p.ProductID,p.ProductName
FROM [Order Details] od
INNER JOIN Products p ON p.ProductID=od.ProductID
WHERE Discount = 0

-- 列出購買非本國的產品的客戶
SELECT
	c.ContactName 
FROM Suppliers s
INNER JOIN Products p ON s.SupplierID=p.SupplierID
INNER JOIN [Order Details] od ON od.ProductID=p.ProductID
INNER JOIN Orders o ON o.OrderID =od.OrderID
INNER JOIN Customers c ON c.CustomerID=o.CustomerID
WHERE s.Country <> c.Country

-- 列出在同個城市中有公司員工可以服務的客戶
SELECT  DISTINCT
	c.CustomerID
FROM Customers c
INNER JOIN Orders o  ON o.CustomerID = c.CustomerID
INNER JOIN Employees e  ON e.EmployeeID = o.EmployeeID
WHERE c.City =e.City
-- 列出那些產品沒有人買過
SELECT
	p.ProductID
FROM Products p
WHERE p.ProductID  NOT IN (
SELECT 
	od.ProductID
FROM [Order Details] od
GROUP BY od.ProductID)

----------------------------------------------------------------------------------------
-- 列出所有在每個月月底的訂單
SELECT
	OrderID,OrderDate
FROM Orders
WHERE OrderDate =EOMONTH(OrderDate)
-- 列出每個月月底售出的產品
SELECT  DISTINCT
	od.ProductID
FROM Orders o
INNER JOIN [Order Details] od ON od.OrderID = o.OrderID
WHERE DAY(o.OrderDate) - DAY(DATEADD(DAY,1,o.OrderDate)) >0
ORDER BY od.ProductID
-- 找出有敗過最貴的三個產品中的任何一個的前三個大客戶
SELECT TOP 3
	o.CustomerID,
	od.ProductID,
	o.OrderID,
	(od.UnitPrice*od.Quantity)*(1-od.Discount) AS S
FROM [Order Details] od
INNER JOIN Orders o ON o.OrderID = od.OrderID
WHERE od.ProductID IN (
SELECT TOP 3
	p.ProductID
FROM Products p
ORDER BY p.UnitPrice DESC)
ORDER BY (od.UnitPrice*od.Quantity)*(1-od.Discount) DESC
-- 找出有敗過銷售金額前三高個產品的前三個大客戶
SELECT TOP 3
	o.CustomerID,
	od.ProductID,
	o.OrderID,
	(od.UnitPrice*od.Quantity)*(1-od.Discount) AS S
FROM [Order Details] od
INNER JOIN Orders o ON o.OrderID = od.OrderID
WHERE od.ProductID IN (
SELECT TOP 3
	ProductID
FROM [Order Details]
GROUP BY ProductID
ORDER BY SUM(UnitPrice*Quantity*(1-Discount)))
ORDER BY (od.UnitPrice*od.Quantity)*(1-od.Discount) DESC
-- 找出有敗過銷售金額前三高個產品所屬類別的前三個大客戶
SELECT TOP 3
	o.CustomerID,
	od.ProductID,
	o.OrderID,
	p.CategoryID,
	(od.UnitPrice*od.Quantity)*(1-od.Discount) AS S
FROM [Order Details] od
INNER JOIN Products p ON p.ProductID = od.ProductID
INNER JOIN Orders o ON o.OrderID = od.OrderID
WHERE p.CategoryID IN (
SELECT TOP 3
	p.CategoryID
FROM [Order Details] ods
INNER JOIN Products p ON p.ProductID = ods.ProductID
GROUP BY ods.ProductID,p.CategoryID
ORDER BY SUM(ods.UnitPrice*ods.Quantity*(1-ods.Discount)))
ORDER BY (od.UnitPrice*od.Quantity)*(1-od.Discount) DESC
--- 列出消費總金額高於所有客戶平均消費總金額的客戶的名字，以及客戶的消費總金額
SELECT 
	o.OrderID,c.ContactName 
FROM Customers c 
INNER JOIN Orders o ON o.CustomerID = c.CustomerID 
WHERE o.OrderID IN (
  SELECT 
	OrderID 
  FROM [Order Details] 
  GROUP BY OrderID 
  HAVING SUM(UnitPrice*Quantity*(1-Discount)) > (SELECT AVG(UnitPrice*Quantity*(1-Discount)) AS total FROM [Order Details])
) 
ORDER BY o.OrderID
-- 列出最熱銷的產品，以及被購買的總金額
SELECT  TOP 1
	od.ProductID,
	COUNT(od.ProductID),
	SUM( (od.UnitPrice*od.Quantity)*(1-od.Discount))
FROM [Order Details] od
GROUP BY od.ProductID
ORDER BY COUNT(od.ProductID) DESC
-- 列出最少人買的產品
SELECT TOP 1
	od.ProductID,
	COUNT(od.ProductID)
FROM [Order Details] od
GROUP BY od.ProductID
ORDER BY COUNT(od.ProductID)
-- 列出最沒人要買的產品類別 (Categories)
SELECT
	c.CategoryName,
	p.ProductID
FROM Categories c
INNER JOIN Products p ON p.CategoryID = c.CategoryID
WHERE p.ProductID = (
SELECT TOP 1
	od.ProductID
FROM [Order Details] od
GROUP BY od.ProductID
ORDER BY COUNT(od.ProductID) )
--- 列出跟銷售最好的供應商買最多金額的客戶與購買金額 (含購買其它供應商的產品)
SELECT 
	c.ContactName,
	SUM(UnitPrice*Quantity*(1-Discount)) AS all_money
FROM Orders o 
INNER JOIN Customers c ON o.CustomerID = c.CustomerID 
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID 
WHERE o.EmployeeID = (
	SELECT TOP 1 
		EmployeeID 
	FROM Orders
	GROUP BY EmployeeID 
	ORDER BY COUNT(OrderID) DESC) 
	GROUP BY c.ContactName 
	order by SUM(UnitPrice*Quantity*(1-Discount)
) DESC
--- 列出跟銷售最好的供應商買最多金額的客戶與購買金額 (不含購買其它供應商的產品)
SELECT
	c.ContactName,
	SUM(UnitPrice*Quantity*(1-Discount)) AS all_money
from Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY c.ContactName
ORDER BY all_money DESC
-- 列出那些產品沒有人買過
SELECT
	p.ProductID
FROM Products p
WHERE p.ProductID  NOT IN (
SELECT 
	od.ProductID
FROM [Order Details] od
GROUP BY od.ProductID)
-- 列出沒有傳真 (Fax) 的客戶和它的消費總金額
SELECT
	c.CustomerID,
	SUM((od.UnitPrice*od.Quantity)-(1-od.Discount))
FROM Customers c
INNER JOIN Orders o ON o.CustomerID = c.CustomerID
INNER JOIN [Order Details] od ON od.OrderID = o.OrderID
WHERE c.CustomerID IN(
SELECT
	c.CustomerID
FROM Customers c
GROUP BY c.CustomerID,c.Fax
HAVING COALESCE(c.Fax,'NULL') = 'NULL')
GROUP BY c.CustomerID
-- 列出每一個城市消費的產品種類數量
SELECT
	c.City,
	COUNT(p.CategoryID)
FROM Customers c
INNER JOIN Orders o ON o.CustomerID = c.CustomerID
INNER JOIN [Order Details] od ON od.OrderID = o.OrderID
INNER JOIN Products p ON p.ProductID = od.ProductID
GROUP BY c.City
-- 列出目前沒有庫存的產品在過去總共被訂購的數量
SELECT
	p.ProductID,
	SUM(od.Quantity)
FROM Products p
INNER JOIN [Order Details] od ON od.ProductID = p.ProductID
WHERE p.ProductID IN(
SELECT
	p.ProductID
FROM Products p
WHERE UnitsInStock =0)
GROUP BY p.ProductID
-- 列出目前沒有庫存的產品在過去曾經被那些客戶訂購過
SELECT
	od.ProductID,
	c.CustomerID
FROM Customers c
INNER JOIN Orders o ON o.CustomerID = c.CustomerID
INNER JOIN [Order Details] od ON od.OrderID = o.OrderID
WHERE od.ProductID IN(
SELECT
	p.ProductID
FROM Products p
WHERE UnitsInStock =0)
ORDER BY od.ProductID
-- 列出每位員工的下屬的業績總金額
SELECT
	e.ReportsTo,
	e.EmployeeID,
	SUM((od.UnitPrice*od.Quantity)*(1-od.Discount))
FROM Employees e
INNER JOIN Orders o ON o.EmployeeID = e.EmployeeID
INNER JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY e.EmployeeID,e.ReportsTo
-- 列出每家貨運公司運送最多的那一種產品類別與總數量
SELECT
	s.CompanyName
FROM Shippers s
INNER JOIN Orders o ON o.ShipVia = s.ShipperID
INNER JOIN [Order Details] od ON od.OrderID = o.OrderID
INNER JOIN Products p ON p.ProductID = od.ProductID
GROUP BY s.CompanyName;
--- 列出每一個客戶買最多的產品類別與金額
WITH clientbuy_Table AS (
	SELECT 
		c.ContactName,
		p.CategoryID, sum(Quantity) AS Quantity,
		sum(od.UnitPrice*Quantity*(1-Discount)) AS total,
		row_number() OVER(PARTITION BY ContactName ORDER BY sum(Quantity) DESC)AS Numbers
	FROM [Order Details] od 
INNER join Orders o ON od.OrderID = o.OrderID 
INNER join Customers c ON c.CustomerID = o.CustomerID 
INNER join Products p ON od.ProductID = p.ProductID 
GROUP BY c.ContactName, p.CategoryID)
SELECT
	* 
FROM clientbuy_Table 
WHERE Numbers = 1;
-- 列出每一個客戶買最多的那一個產品與購買數量
WITH clientbuy_Table AS (
	SELECT 
		c.ContactName,
		p.ProductName,
		sum(Quantity) AS Quantity,
		row_number() OVER(PARTITION BY ContactName ORDER BY c.ContactName,
		sum(Quantity) DESC) AS Numbers
	FROM [Order Details] od 
	INNER join Orders o ON od.OrderID = o.OrderID 
	INNER join Customers c ON c.CustomerID = o.CustomerID 
	INNER join Products p ON od.ProductID = p.ProductID 
	GROUP BY c.ContactName, p.ProductName)
SELECT
	* 
FROM clientbuy_Table
WHERE Numbers = 1;
-- 按照城市分類，找出每一個城市最近一筆訂單的送貨時間
SELECT
	c.City,
	MAX(o.ShippedDate)
FROM Orders o
INNER JOIN Customers c ON c.CustomerID = o.CustomerID
GROUP BY c.City
-- 列出購買金額第五名與第十名的客戶，以及兩個客戶的金額差距
SELECT 
	o.CustomerID,
	SUM((od.UnitPrice*od.Quantity)*(1-od.Discount))AS S
FROM Orders o
INNER JOIN [Order Details] od ON od.OrderID = o.OrderID
GROUP BY o.CustomerID
ORDER BY SUM((od.UnitPrice*od.Quantity)*(1-od.Discount)) DESC
