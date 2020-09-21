USE AdventureWorks2012;
GO

/*
	a) —оздайте таблицу Production.LocationHst, котора€ будет хранить информацию об изменени€х в таблице Production.Location.
	ќб€зательные пол€, которые должны присутствовать в таблице: 
	ID Ч первичный ключ IDENTITY(1,1); 
	Action Ч совершенное действие (insert, update или delete); 
	ModifiedDate Ч дата и врем€, когда была совершена операци€; 
	SourceID Ч первичный ключ исходной таблицы; 
	UserName Ч им€ пользовател€, совершившего операцию. 
	—оздайте другие пол€, если считаете их нужными.
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
	b) —оздайте один AFTER триггер дл€ трех операций INSERT, UPDATE, DELETE дл€ таблицы Production.Location. 
	“риггер должен заполн€ть таблицу Production.LocationHst с указанием типа операции в поле Action в зависимости от оператора, вызвавшего триггер.
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
	c) —оздайте представление VIEW, отображающее все пол€ таблицы Production.Location.
*/
CREATE VIEW LocationView AS 
SELECT * FROM Production.Location;
GO

/*
	d) ¬ставьте новую строку в Production.Location через представление. 
	ќбновите вставленную строку. ”далите вставленную строку. 
	”бедитесь, что все три операции отображены в Production.LocationHst.
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