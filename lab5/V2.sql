USE AdventureWorks2012;
GO

/*
	�������� scalar-valued �������, ������� ����� ��������� � �������� �������� ��������� id ������ 
	(HumanResources.Department.DepartmentID) � ���������� ���������� �����������, ���������� � ������.
*/
CREATE FUNCTION HumanResources.getDepartmentEmployeeCount(@dID INT)
RETURNS INT
AS
BEGIN
	RETURN (
		SELECT COUNT(*) 
		FROM EmployeeDepartmentHistory 
		WHERE EndDate IS NULL AND DepartmentID = @dID
	);
END;
GO

PRINT HumanResources.getDepartmentEmployeeCount(1);
GO

SELECT *
FROM HumanResources.EmployeeDepartmentHistory 
WHERE EndDate IS NULL AND DepartmentID = 1;
GO

/*
	�������� inline table-valued �������, ������� ����� ��������� � �������� �������� ��������� id ������ 
	(HumanResources.Department.DepartmentID), � ���������� �����������, ������� �������� � ������ ����� 11 ���.
*/
CREATE FUNCTION HumanResources.getDepartmentEmployees(@dID INT)
RETURNS TABLE
AS 
RETURN (
	SELECT * FROM EmployeeDepartmentHistory
	WHERE DepartmentID = @dID AND 
		EndDate IS NULL AND 
		DATEDIFF(YEAR, StartDate, GETDATE()) > 11 
);
GO

SELECT * FROM HumanResources.getDepartmentEmployees(1);
GO

/*
	�������� ������� ��� ������� ������, �������� �������� CROSS APPLY. 
	�������� ������� ��� ������� ������, �������� �������� OUTER APPLY.
*/
SELECT 
	dep.DepartmentID,
	BusinessEntityID,
	ShiftID,
	StartDate, 
	EndDate,
	emps.ModifiedDate
FROM
HumanResources.Department AS dep
CROSS APPLY
HumanResources.getDepartmentEmployees(dep.DepartmentID) as emps
ORDER BY dep.DepartmentID;
GO

SELECT 
	dep.DepartmentID,
	BusinessEntityID,
	ShiftID,
	StartDate, 
	EndDate,
	emps.ModifiedDate
FROM
HumanResources.Department AS dep
OUTER APPLY
HumanResources.getDepartmentEmployees(dep.DepartmentID) as emps
ORDER BY dep.DepartmentID;
GO

/*
	�������� ��������� inline table-valued �������, ������ �� multistatement table-valued
	(�������������� �������� ��� �������� ��� �������� inline table-valued �������).
*/
CREATE FUNCTION HumanResources.getDepartmentEmployees2(@dID INT)
RETURNS @emplyees TABLE (
	DepartmentID SMALLINT NOT NULL,
	BusinessEntityID INT NOT NULL,
	ShiftID TINYINT NOT NULL,
	StartDate DATE NOT NULL, 
	EndDate DATE NULL,
	ModifiedDate DATETIME NOT NULL
) AS
BEGIN
	INSERT INTO @emplyees
	SELECT *
	FROM EmployeeDepartmentHistory 
	WHERE DepartmentID = @dID AND 
		  EndDate IS NULL AND 
		  DATEDIFF(YEAR, StartDate, GETDATE()) > 11;
	RETURN;
END;
GO

SELECT *
FROM HumanResources.getDepartmentEmployees2(1);
GO
