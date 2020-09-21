USE AdventureWorks2012;
GO

/*
	a)	�������� ������� dbo.PersonPhone � ����� �� ���������� ��� Person.PersonPhone, �� ������� �������, ����������� � ��������
*/
CREATE TABLE dbo.PersonPhone (
	BusinessEntityID INT NOT NULL,
	PhoneNumber NVARCHAR(25) NOT NULL,
	PhoneNumberTypeID INT NOT NULL,
	ModifiedDate DATETIME NOT NULL
);
GO

/*
	b) ��������� ���������� ALTER TABLE, �������� � ������� dbo.PersonPhone ����� ���� ID, 
	������� �������� ���������� ������������ UNIQUE ���� bigint � ����� �������� identity. 
	��������� �������� ��� ���� identity ������� 2 � ���������� ������� 2;
*/
ALTER TABLE dbo.PersonPhone ADD ID BIGINT IDENTITY(2,2) UNIQUE;
GO

/*
	c) ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.PersonPhone ����������� ��� ���� PhoneNumber, 
	����������� ���������� ����� ���� �������;
*/
ALTER TABLE dbo.PersonPhone
ADD CONSTRAINT Check_PhoneNumber
CHECK (PATINDEX('%[a-zA-Z]%', PhoneNumber) = 0);
GO

/*
	d) ��������� ���������� ALTER TABLE, �������� ��� ������� dbo.PersonPhone ����������� DEFAULT ��� ���� PhoneNumberTypeID, 
	������� �������� �� ��������� 1;
*/
ALTER TABLE dbo.PersonPhone
  ADD CONSTRAINT DF_PhoneNumberTypeID
  DEFAULT 1 FOR PhoneNumberTypeID;
GO

/*
	e) ��������� ����� ������� ������� �� Person.PersonPhone, 
	��� ���� PhoneNumber �� �������� �������� �(� � �)� � ������ ��� ��� �����������, 
	������� ���������� � ������� HumanResources.Employee, 
	� �� ���� �������� �� ������ ��������� � ����� ������ ������ � ������;
*/
INSERT INTO dbo.PersonPhone
SELECT 
	pp.BusinessEntityID, 
	pp.PhoneNumber, 
	pp.PhoneNumberTypeID, 
	pp.ModifiedDate
FROM Person.PersonPhone AS pp
INNER JOIN HumanResources.Employee AS emp
ON pp.BusinessEntityID = emp.BusinessEntityID
INNER JOIN HumanResources.EmployeeDepartmentHistory AS edh
ON emp.BusinessEntityID = edh.BusinessEntityID
WHERE  PhoneNumber NOT LIKE '%[()]%' AND emp.HireDate = edh.StartDate;
GO

SELECT * FROM dbo.PersonPhone;
GO

/*
	f) �������� ���� PhoneNumber, �������� ���������� null ��������.
*/
ALTER TABLE dbo.PersonPhone
ALTER COLUMN PhoneNumber NVARCHAR(25) NULL;
GO

