USE AdventureWorks2012;
GO

/*
	a) �������� ������� Production.LocationHst, ������� ����� ������� ���������� �� ���������� � ������� Production.Location.
	������������ ����, ������� ������ �������������� � �������: 
	ID � ��������� ���� IDENTITY(1,1); 
	Action � ����������� �������� (insert, update ��� delete); 
	ModifiedDate � ���� � �����, ����� ���� ��������� ��������; 
	SourceID � ��������� ���� �������� �������; 
	UserName � ��� ������������, ������������ ��������. 
	�������� ������ ����, ���� �������� �� �������.
*/
CREATE TABLE Production.LocationHst (
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Action NVARCHAR(8) NOT NULL, 
	ModifiedDate DATETIME NOT NULL,
	SourceID INT NOT NULL,
	UserName NVARCHAR(25) NOT NULL
);
GO

/*
	b) �������� ���� AFTER ������� ��� ���� �������� INSERT, UPDATE, DELETE ��� ������� Production.Location. 
	������� ������ ��������� ������� Production.LocationHst � ��������� ���� �������� � ���� Action � ����������� �� ���������, ���������� �������.
*/
CREATE TRIGGER Production_Location_TR
ON Production.Location
AFTER INSERT, UPDATE, DELETE   
AS
	IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
		INSERT INTO Production.LocationHst 
		SELECT 
			'update',
			CURRENT_TIMESTAMP,
			LocationID,
			CURRENT_USER
		FROM inserted
	ELSE IF EXISTS (SELECT * FROM inserted)
		INSERT INTO Production.LocationHst 
		SELECT 
			'insert',
			CURRENT_TIMESTAMP,
			LocationID,
			CURRENT_USER
		FROM inserted
	ELSE IF EXISTS (SELECT * FROM deleted)
		INSERT INTO Production.LocationHst
		SELECT 
			'delete',
			CURRENT_TIMESTAMP,
			LocationID,
			CURRENT_USER
		FROM deleted;	
GO

SET IDENTITY_INSERT Production.Location ON;
GO

INSERT INTO Production.Location (
	LocationID, 
	Name, 
	CostRate, 
	Availability, 
	ModifiedDate
) VALUES (
	666,
	'DB',
	12,
	0.6,
	CURRENT_TIMESTAMP
);	
GO

SET IDENTITY_INSERT Production.Location OFF;
GO

UPDATE Production.Location 
SET Name = 'db' 
WHERE LocationID = 666;	
GO

DELETE FROM Production.Location
WHERE LocationID = 666;
GO

SELECT * FROM Production.LocationHst 
WHERE SourceID = 666;
GO

/*
	c) �������� ������������� VIEW, ������������ ��� ���� ������� Production.Location.
*/
CREATE VIEW LocationView AS 
SELECT * FROM Production.Location;
GO

/*
	d) �������� ����� ������ � Production.Location ����� �������������. 
	�������� ����������� ������. ������� ����������� ������. 
	���������, ��� ��� ��� �������� ���������� � Production.LocationHst.
*/
SET IDENTITY_INSERT Production.Location ON;
GO

INSERT INTO LocationView (
	LocationID, 
	Name, 
	CostRate, 
	Availability, 
	ModifiedDate
) VALUES (
	666,
	'DBo',
	12,
	0.6,
	CURRENT_TIMESTAMP
);	
GO

SET IDENTITY_INSERT Production.Location OFF;
GO

SELECT * FROM LocationView
WHERE LocationID = 666;
GO

UPDATE LocationView
SET Name = 'dbo' 
WHERE LocationID = 666;	
GO

DELETE FROM LocationView
WHERE LocationID = 666;
GO

SELECT * FROM Production.LocationHst
WHERE SourceID = 666;
GO