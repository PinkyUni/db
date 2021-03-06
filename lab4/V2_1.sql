USE AdventureWorks2012;
GO

/*
	a) Создайте таблицу Production.LocationHst, которая будет хранить информацию об изменениях в таблице Production.Location.
	Обязательные поля, которые должны присутствовать в таблице: 
	ID — первичный ключ IDENTITY(1,1); 
	Action — совершенное действие (insert, update или delete); 
	ModifiedDate — дата и время, когда была совершена операция; 
	SourceID — первичный ключ исходной таблицы; 
	UserName — имя пользователя, совершившего операцию. 
	Создайте другие поля, если считаете их нужными.
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
	b) Создайте один AFTER триггер для трех операций INSERT, UPDATE, DELETE для таблицы Production.Location. 
	Триггер должен заполнять таблицу Production.LocationHst с указанием типа операции в поле Action в зависимости от оператора, вызвавшего триггер.
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
	c) Создайте представление VIEW, отображающее все поля таблицы Production.Location.
*/
CREATE VIEW LocationView AS 
SELECT * FROM Production.Location;
GO

/*
	d) Вставьте новую строку в Production.Location через представление. 
	Обновите вставленную строку. Удалите вставленную строку. 
	Убедитесь, что все три операции отображены в Production.LocationHst.
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