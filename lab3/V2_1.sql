USE AdventureWorks2012;
GO

/*
	a) �������� � ������� dbo.PersonPhone ���� HireDate ���� date;
*/
ALTER TABLE dbo.PersonPhone ADD HireDate DATE;
GO

/*
	b)	�������� ��������� ���������� � ����� �� ���������� ��� dbo.PersonPhone � ��������� �� ������� �� dbo.PersonPhone. 
	��������� ���� HireDate ���������� �� ���� HireDate ������� HumanResources.Employee;
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
	pp.BusinessEntityID, 
	PhoneNumber,
	PhoneNumberTypeID,
	pp.ModifiedDate,
	ID,
	emp.HireDate
FROM dbo.PersonPhone AS pp
INNER JOIN HumanResources.Employee AS emp
ON pp.BusinessEntityID = emp.BusinessEntityID;


/*
	c) �������� HireDate � dbo.PersonPhone ������� �� ��������� ����������, ������� � HireDate ���� ����;
*/

 UPDATE dbo.PersonPhone
 SET dbo.PersonPhone.HireDate = DATEADD(DAY, 1, pPhone.HireDate)
 FROM dbo.PersonPhone AS pp
 INNER JOIN @personPhone AS pPhone
 ON pp.BusinessEntityID = pPhone.BusinessEntityID;

 SELECT * FROM dbo.PersonPhone;
 GO	

 /*
	d)	������� ������ �� dbo.PersonPhone, ��� ��� �����������, 
	� ������� ��������� ������ � ������� HumanResources.EmployeePayHistory ������ 50;
 */
 DELETE FROM dbo.PersonPhone
 WHERE EXISTS (
	SELECT BusinessEntityID
	FROM HumanResources.EmployeePayHistory AS eph
	WHERE dbo.PersonPhone.BusinessEntityID = eph.BusinessEntityID AND Rate > 50
);
GO

SELECT * FROM HumanResources.EmployeePayHistory 
WHERE Rate > 50;
GO

 /*
	e)	������� ��� ��������� ����������� � �������� �� ���������. ����� �����, ������� ���� ID.
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
	f)	������� ������� dbo.PersonPhone.
*/
DROP TABLE dbo.PersonPhone;
GO