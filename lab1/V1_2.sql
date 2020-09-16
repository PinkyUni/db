USE AdventureWorks2012;
GO

/*
	Вывести на экран сотрудников, позиция которых находится в списке: 
	‘Accounts Manager’,’Benefits Specialist’,’Engineering Manager’,
	’Finance Manager’,’Maintenance Supervisor’,’Master Scheduler’,’Network Manager’
*/
SELECT BusinessEntityID, JobTitle,Gender, HireDate 
FROM HumanResources.Employee 
WHERE JobTitle IN 
('Accounts Manager','Benefits Specialist','Engineering Manager',
'Finance Manager','Maintenance Supervisor','Master Scheduler','Network Manager');
GO

/*
	Вывести на экран количество сотрудников, принятых на работу позже 2004 года (включая 2004 год).
*/
SELECT COUNT(*) AS EmpCount
FROM HumanResources.Employee 
WHERE YEAR(HireDate) >= 2004;
GO

/*
	Вывести на экран 5(пять) самых молодых сотрудников, состоящих в браке, которые были приняты на работу в 2004 году.
*/
SELECT TOP 5 BusinessEntityID, JobTitle, MaritalStatus, Gender, BirthDate, HireDate 
FROM HumanResources.Employee
WHERE MaritalStatus = 'M' and YEAR(HireDate) = 2004
ORDER BY BirthDate desc;
GO

