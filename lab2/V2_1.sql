USE AdventureWorks2012;
GO

/*
	Вывести на экран историю сотрудника, который работает на позиции ‘Purchasing Manager’.
	В каких отделах компании он работал, с указанием периодов работы в каждом отделе.
*/

SELECT Employee.BusinessEntityID, JobTitle, Department.Name AS DepartmentName, StartDate, EndDate
FROM HumanResources.Employee
INNER JOIN HumanResources.EmployeeDepartmentHistory 
ON HumanResources.Employee.BusinessEntityID = EmployeeDepartmentHistory.BusinessEntityID
INNER JOIN HumanResources.Department 
ON EmployeeDepartmentHistory.DepartmentID = Department.DepartmentID
WHERE JobTitle = 'Purchasing Manager';
GO

/*
	Вывести на экран список сотрудников, у которых почасовая ставка изменялась хотя бы один раз.
*/

SELECT Employee.BusinessEntityID, JobTitle, COUNT(*) AS RateCount
FROM HumanResources.EmployeePayHistory
INNER JOIN HumanResources.Employee
ON HumanResources.Employee.BusinessEntityID = EmployeePayHistory.BusinessEntityID 
GROUP BY Employee.BusinessEntityID, JobTitle
HAVING COUNT(*) > 1;
GO

/*
	Вывести на экран максимальную почасовую ставку в каждом отделе. 
	Вывести только актуальную информацию. Если сотрудник больше не работает в отделе — не учитывать такие данные
*/

SELECT Department.DepartmentID, Department.Name, MAX(EmployeePayHistory.Rate) AS MaxRate
FROM HumanResources.EmployeePayHistory
INNER JOIN HumanResources.EmployeeDepartmentHistory
ON  HumanResources.EmployeeDepartmentHistory.BusinessEntityID = HumanResources.EmployeePayHistory.BusinessEntityID
INNER JOIN HumanResources.Department
ON HumanResources.Department.DepartmentID = HumanResources.EmployeeDepartmentHistory.DepartmentID
WHERE EndDate IS NULL
GROUP BY Department.DepartmentID, Department.Name
ORDER BY Department.DepartmentID;
GO