USE AdventureWorks2012;
GO

/*
	a) ��������� ���, ��������� �� ������ ������� ������ ������������ ������. 
	�������� � ������� dbo.PersonPhone ���� JobTitle NVARCHAR(50), BirthDate DATE � HireDate DATE. 
	����� �������� � ������� ����������� ���� HireAge, ��������� ���������� ���, ��������� ����� BirthDate � HireDate.
*/
ALTER TABLE dbo.PersonPhone 
ADD 
	JobTitle NVARCHAR(50), 
	BirthDate DATE, 
	HireDate DATE,
	HireAge AS DATEDIFF(YEAR, BirthDate, HireDate
);
GO

/*
	b) �������� ��������� ������� #PersonPhone, � ��������� ������ �� ���� BusinessEntityID.
	��������� ������� ������ �������� ��� ���� ������� dbo.PersonPhone �� ����������� ���� HireAge.
*/
CREATE TABLE #PersonPhone (
	BusinessEntityID INT NOT NULL PRIMARY KEY,
	PhoneNumber NVARCHAR(25) NULL,
	PhoneNumberTypeID INT NOT NULL,
	ModifiedDate DATETIME NOT NULL,
	ID BIGINT NOT NULL,
	JobTitle NVARCHAR(25) NULL,
	BirthDate DATE NULL,
	HireDate DATE NULL
);
GO

/*
	c) ��������� ��������� ������� ������� �� dbo.PersonPhone. 
	���� JobTitle, BirthDate � HireDate ��������� ���������� �� ������� HumanResources.Employee. 
	�������� ������ ����������� � JobTitle = �Sales Representative�. 
	������� ������ ��� ������� � ��������� ���������� ����������� � Common Table Expression (CTE).
*/
delete from #PersonPhone;
WITH cte AS (
SELECT 
	dbo.PersonPhone.BusinessEntityID,
	dbo.PersonPhone.PhoneNumber,
	dbo.PersonPhone.PhoneNumberTypeID,
	dbo.PersonPhone.ModifiedDate,
	dbo.PersonPhone.ID,
	HumanResources.Employee.JobTitle, 
	HumanResources.Employee.BirthDate, 
	HumanResources.Employee.HireDate
FROM dbo.PersonPhone
INNER JOIN HumanResources.Employee
ON HumanResources.Employee.BusinessEntityID = dbo.PersonPhone.BusinessEntityID
WHERE HumanResources.Employee.JobTitle = 'Sales Representative'
)
INSERT INTO #PersonPhone  
SELECT * FROM cte;
GO

SELECT * FROM #PersonPhone;
GO

/*
	d) ������� �� ������� dbo.PersonPhone ���� ������ (��� BusinessEntityID = 275)
*/

DELETE FROM dbo.PersonPhone
WHERE BusinessEntityID = 275;
GO

SELECT COUNT(*) FROM dbo.PersonPhone
WHERE BusinessEntityID = 275;
GO

/*
	e) �������� Merge ���������, ������������ dbo.PersonPhone ��� target, � ��������� ������� ��� source. 
	��� ����� target � source ����������� BusinessEntityID. �������� ���� JobTitle, BirthDate � HireDate, 
	���� ������ ������������ � � source � � target. ���� ������ ������������ �� ��������� �������,
	�� �� ���������� � target, �������� ������ � dbo.PersonPhone. ���� � dbo.PersonPhone ������������ ����� ������, 
	������� �� ���������� �� ��������� �������, ������� ������ �� dbo.PersonPhone. 
*/		
SET IDENTITY_INSERT dbo.PersonPhone ON;
GO

MERGE dbo.PersonPhone AS t
USING #PersonPhone AS s
ON t.BusinessEntityID = s.BusinessEntityID
WHEN MATCHED THEN
UPDATE SET 
	t.JobTitle = s.JobTitle,
	t.BirthDate = s.BirthDate,
	t.HireDate = s.HireDate
WHEN NOT MATCHED BY TARGET THEN
INSERT (
	BusinessEntityID,
	PhoneNumber,
	PhoneNumberTypeID,
	ModifiedDate,
	ID,
	JobTitle, 
	BirthDate, 
	HireDate
)
VALUES (
	s.BusinessEntityID,	
	s.PhoneNumber,
	s.PhoneNumberTypeID,
	s.ModifiedDate,
	s.ID,
	s.JobTitle, 
	s.BirthDate, 
	s.HireDate
)
WHEN NOT MATCHED BY SOURCE THEN
DELETE;
GO

SET IDENTITY_INSERT dbo.PersonPhone OFF;
GO

SELECT COUNT(*) FROM dbo.PersonPhone
WHERE BusinessEntityID = 275;
GO