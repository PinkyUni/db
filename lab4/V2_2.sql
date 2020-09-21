USE AdventureWorks2012;
GO

/*
	a) �������� ������������� VIEW, ������������ ������ �� ������ Production.Location � Production.ProductInventory, 
	� ����� Name �� ������� Production.Product. �������� ����������� �������� ��������� ���� �������������. 
	�������� ���������� ���������� ������ � ������������� �� ����� LocationID,ProductID.
*/
CREATE VIEW ProductInfoView 
WITH SCHEMABINDING, ENCRYPTION AS 
SELECT 
	l.LocationID,
	l.Name AS LocationName,
	l.CostRate,
	l.Availability,
	l.ModifiedDate AS LocationModifiedDate,
	ppi.ProductID,
	ppi.Shelf,
	ppi.Bin,
	ppi.Quantity,
	ppi.rowguid,
	ppi.ModifiedDate AS ProductInventoryModifiedDate,
	p.Name
FROM Production.Location AS l
INNER JOIN Production.ProductInventory AS ppi
ON l.LocationID = ppi.LocationID
INNER JOIN Production.Product AS p
ON ppi.ProductID = p.ProductID;
GO

CREATE UNIQUE CLUSTERED INDEX ProductInfo_IX
	ON ProductInfoView(LocationID, ProductID); 
GO

/*
	b) �������� ��� INSTEAD OF �������� ��� ������������� �� �������� INSERT, UPDATE, DELETE. 
	������ ������� ������ ��������� ��������������� �������� � �������� Production.Location 
	� Production.ProductInventory ��� ���������� Product Name. 
	���������� � �������� ����� ����������� ������ � �������� Production.Location � Production.ProductInventory, �� �� � Production.Product.
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
	INNER JOIN Production.Product AS p
	ON inserted.Name = p.Name;
	INSERT INTO Production.ProductInventory
	SELECT
		p.ProductID,
		l.LocationID,
		Shelf,
		Bin,
		Quantity,
		inserted.rowguid,
		ProductInventoryModifiedDate
	FROM inserted
	INNER JOIN Production.Product AS p
	ON inserted.Name = p.Name
	INNER JOIN Production.Location AS l
	ON inserted.LocationName = l.Name;
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
		FROM Production.Location AS l
		INNER JOIN inserted
		ON inserted.LocationID = l.LocationID;
		UPDATE Production.ProductInventory
		SET 
			Shelf = inserted.Shelf,
			Bin = inserted.Bin,
			Quantity = inserted.Quantity,
			rowguid = inserted.rowguid,
			ModifiedDate = inserted.ProductInventoryModifiedDate
		FROM Production.ProductInventory AS ppi
		INNER JOIN inserted
		ON ppi.ProductID = inserted.ProductID;		
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
GO
/*
	c) �������� ����� ������ � �������������, ������ ����� ������ ��� Location � ProductInventory, 
	�� ��� ������������� Product (�������� ��� �Adjustable Race�). 
	������� ������ �������� ����� ������ � ������� Production.Location � Production.ProductInventory ��� ���������� Product Name. 
	�������� ����������� ������ ����� �������������. ������� ������.
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
	'SHELF',
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

SELECT ppi.LocationID, p.Name, CostRate 
FROM Production.Location
INNER JOIN Production.ProductInventory AS ppi
ON ppi.LocationID = Production.Location.LocationID
INNER JOIN Production.Product AS p
ON p.ProductID = ppi.ProductID
WHERE p.Name = 'Blade';
GO

UPDATE ProductInfoView
SET Quantity = 8
WHERE Name = 'Blade';
GO

SELECT Name, Quantity
FROM Production.ProductInventory AS ppi
INNER JOIN Production.Product AS p
ON ppi.ProductID = p.ProductID
WHERE Name = 'Blade';
GO

DELETE FROM ProductInfoView
WHERE Name = 'Blade';	
GO

SELECT COUNT(*) AS recCount
FROM Production.Location AS l
INNER JOIN Production.ProductInventory AS ppi
ON ppi.LocationID = l.LocationID
INNER JOIN Production.Product AS p
ON p.ProductID = ppi.ProductID
WHERE p.Name = 'Blade';
GO
