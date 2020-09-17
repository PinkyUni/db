USE AdventureWorks2012;
GO

/*
	a) добавьте в таблицу dbo.PersonPhone поле HireDate типа date;
*/
ALTER TABLE dbo.PersonPhone ADD HireDate DATE;
GO

/*
	b)	объявите табличную переменную с такой же структурой как dbo.PersonPhone и заполните ее данными из dbo.PersonPhone. 
	Заполните поле HireDate значениями из поля HireDate таблицы HumanResources.Employee;
*/
DECLARE @personPhone TABLE (
	BusinessEntityID INT NOT NULL,
	PhoneNumber NVARCHAR(25) NULL,
	PhoneNumberTypeID BIGINT NOT NULL,
	ModifiedDate DATETIME NOT NULL,
	ID BIGINT NOT NULL,
	HireDate DATE NULL);
INSERT INTO @personPhone 
SELECT 
	PersonPhone.BusinessEntityID, 
	PhoneNumber,
	PhoneNumberTypeID,
	PersonPhone.ModifiedDate,
	ID,
	HumanResources.Employee.HireDate
	FROM dbo.PersonPhone
INNER JOIN HumanResources.Employee
ON dbo.PersonPhone.BusinessEntityID = HumanResources.Employee.BusinessEntityID;

/*SELECT * FROM @personPhone;*/

/*
	c) обновите HireDate в dbo.PersonPhone данными из табличной переменной, добавив к HireDate один день;
*/

 UPDATE dbo.PersonPhone
 SET dbo.PersonPhone.HireDate = DATEADD(DAY, 1, pPhone.HireDate)
 FROM dbo.PersonPhone 
 INNER JOIN @personPhone AS pPhone
 ON dbo.PersonPhone.BusinessEntityID = pPhone.BusinessEntityID;

 SELECT * FROM dbo.PersonPhone;
 GO	

 /*
	d)	удалите данные из dbo.PersonPhone, для тех сотрудников, 
	у которых почасовая ставка в таблице HumanResources.EmployeePayHistory больше 50;
 */
 DELETE FROM dbo.PersonPhone
 WHERE EXISTS (
	SELECT BusinessEntityID
	FROM HumanResources.EmployeePayHistory
	WHERE dbo.PersonPhone.BusinessEntityID = HumanResources.EmployeePayHistory.BusinessEntityID AND Rate > 50
);
GO

SELECT * FROM HumanResources.EmployeePayHistory 
WHERE Rate > 50;
GO

 /*
	e)	удалите все созданные ограничения и значения по умолчанию. После этого, удалите поле ID.
*/

SELECT *
FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'PersonPhone';
GO

SELECT *
FROM AdventureWorks2012.INFORMATION_SCHEMA.CHECK_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'dbo';
GO

ALTER TABLE dbo.PersonPhone 
DROP CONSTRAINT Check_PhoneNumber, DF_PhoneNumberTypeID, UQ__PersonPh__3214EC260E75607B;
GO

ALTER TABLE dbo.PersonPhone
DROP COLUMN ID;
GO

/*
	f)	удалите таблицу dbo.PersonPhone.
*/
DROP TABLE dbo.PersonPhone;
GO