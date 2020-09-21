USE AdventureWorks2012;
GO

/*
	a) Создайте представление VIEW, отображающее данные из таблиц Production.Location и Production.ProductInventory, 
	а также Name из таблицы Production.Product. Сделайте невозможным просмотр исходного кода представления. 
	Создайте уникальный кластерный индекс в представлении по полям LocationID,ProductID.
*/
CREATE VIEW ProductInfoView 
WITH SCHEMABINDING, ENCRYPTION AS 
SELECT 
	Production.Location.LocationID,
	Production.Location.Name AS LocationName,
	Production.Location.CostRate,
	Production.Location.Availability,
	Production.Location.ModifiedDate AS LocationModifiedDate,
	Production.ProductInventory.ProductID,
	Production.ProductInventory.Shelf,
	Production.ProductInventory.Bin,
	Production.ProductInventory.Quantity,
	Production.ProductInventory.rowguid,
	Production.ProductInventory.ModifiedDate AS ProductInventoryModifiedDate,
	Production.Product.Name
FROM Production.Location
INNER JOIN Production.ProductInventory
ON Production.Location.LocationID = Production.ProductInventory.LocationID
INNER JOIN Production.Product
ON Production.ProductInventory.ProductID = Production.Product.ProductID;
GO

CREATE UNIQUE CLUSTERED INDEX ProductInfo_IX
	ON ProductInfoView(LocationID, ProductID); 
GO

/*
	b) Создайте три INSTEAD OF триггера для представления на операции INSERT, UPDATE, DELETE. 
	Каждый триггер должен выполнять соответствующие операции в таблицах Production.Location 
	и Production.ProductInventory для указанного Product Name. 
	Обновление и удаление строк производите только в таблицах Production.Location и Production.ProductInventory, но не в Production.Product.
*/
CREATE TRIGGER ProductInfo_Ins_TR
ON ProductInfoView
INSTEAD OF INSERT AS
BEGIN
	INSERT INTO Production.Location 
	SELECT 
		LocationName,
		CostRate,
		Availability,
		LocationModifiedDate
	FROM inserted 
	INNER JOIN Production.Product
	ON inserted.Name = Production.Product.Name;
	INSERT INTO Production.ProductInventory
	SELECT
		Production.Product.ProductID,
		Production.Location.LocationID,
		Shelf,
		Bin,
		Quantity,
		inserted.rowguid,
		ProductInventoryModifiedDate
	FROM inserted
	INNER JOIN Production.Product
	ON inserted.Name = Production.Product.Name
	INNER JOIN Production.Location
	ON inserted.LocationName = Production.Location.Name;
END;
GO

CREATE TRIGGER ProductInfo_Upd_TR
ON ProductInfoView
INSTEAD OF UPDATE AS 
BEGIN
	IF UPDATE(LocationID) OR UPDATE(ProductID)
	BEGIN
		RAISERROR ('UPDATE of Primary Key through ProductInfoView is prohibited.', 16, 1);
		ROLLBACK;
	END
	ELSE
	BEGIN
		UPDATE Production.Location
		SET 
			Name = inserted.LocationName,
			CostRate = inserted.CostRate,
			Availability = inserted.Availability,
			ModifiedDate = inserted.LocationModifiedDate
		FROM Production.Location
		INNER JOIN inserted
		ON inserted.LocationID = Production.Location.LocationID;
		UPDATE Production.ProductInventory
		SET 
			Shelf = inserted.Shelf,
			Bin = inserted.Bin,
			Quantity = inserted.Quantity,
			rowguid = inserted.rowguid,
			ModifiedDate = inserted.ProductInventoryModifiedDate
		FROM Production.ProductInventory
		INNER JOIN inserted
		ON Production.ProductInventory.ProductID = inserted.ProductID;		
	END;
END;
GO

CREATE TRIGGER ProductInfo_Del_TR
ON ProductInfoView
INSTEAD OF DELETE AS 
BEGIN
	DECLARE @pID INT;
	SELECT @pID = (SELECT ProductID FROM deleted);
	CREATE TABLE #locations (
		LocationID SMALLINT NOT NULL
	);
	INSERT INTO #locations 
	SELECT DISTINCT p.LocationID 
	FROM Production.ProductInventory AS p
	INNER JOIN deleted
	ON deleted.ProductID = p.ProductID
	WHERE p.LocationID NOT IN (
		SELECT DISTINCT ppi.LocationID 
		FROM Production.ProductInventory as ppi 
		WHERE ppi.ProductID != @pID
	); 
	DELETE p
	FROM Production.ProductInventory AS p
	WHERE p.ProductID = @pID;
	DELETE l 
	FROM Production.Location AS l
	WHERE LocationID IN (SELECT * FROM #locations);
END;

/*
	c) Вставьте новую строку в представление, указав новые данные для Location и ProductInventory, 
	но для существующего Product (например для ‘Adjustable Race’). 
	Триггер должен добавить новые строки в таблицы Production.Location и Production.ProductInventory для указанного Product Name. 
	Обновите вставленные строки через представление. Удалите строки.
*/
INSERT INTO ProductInfoView (
	LocationName,
	CostRate,
	Availability,
	LocationModifiedDate,
	Shelf,
	Bin,
	Quantity,
	rowguid,
	ProductInventoryModifiedDate,
	Name
) VALUES (
	'smth',
	66.6,
	0.6,
	CURRENT_TIMESTAMP,
	'A',
	6,
	666,
	'47A24246-6C43-48EB-968F-025738A8A410',
	CURRENT_TIMESTAMP,
	'Blade'
);
GO

SELECT * FROM Production.Location
WHERE Name = 'SHELF';
GO

SELECT TOP 2 * FROM Production.ProductInventory
ORDER BY ModifiedDate DESC;
GO

UPDATE ProductInfoView
SET LocationID = 3
WHERE Name = 'Blade';
GO

UPDATE ProductInfoView
SET CostRate = 8.8
WHERE Name = 'Blade';
GO

SELECT ProductInventory.LocationID, Product.Name, CostRate FROM Production.Location
INNER JOIN Production.ProductInventory
ON Production.ProductInventory.LocationID = Production.Location.LocationID
INNER JOIN Production.Product
ON Production.Product.ProductID = Production.ProductInventory.ProductID
WHERE Product.Name = 'Blade';
GO

UPDATE ProductInfoView
SET Quantity = 8
WHERE Name = 'Blade';
GO

SELECT Name, Quantity FROM Production.ProductInventory
INNER JOIN Production.Product
ON Production.ProductInventory.ProductID = Production.Product.ProductID
WHERE Name = 'Blade';
GO

DELETE FROM ProductInfoView
WHERE Name = 'Blade';	
GO

SELECT COUNT(*) AS recCount
FROM Production.Location
INNER JOIN Production.ProductInventory
ON Production.ProductInventory.LocationID = Production.Location.LocationID
INNER JOIN Production.Product
ON Production.Product.ProductID = Production.ProductInventory.ProductID
WHERE Product.Name = 'Blade';
GO
