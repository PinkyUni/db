USE master;
GO

CREATE DATABASE NewDatabase;
GO

USE NewDatabase;
GO

CREATE SCHEMA sales;
GO

CREATE SCHEMA persons;
GO

CREATE TABLE sales.Orders (OrderNum INT NULL);
GO

BACKUP DATABASE NewDatabase TO DISK = 'D:\db\Anya_Beliatskaya.bak';
GO

USE MASTER;
GO

DROP DATABASE NewDatabase;
GO

RESTORE DATABASE NewDatabase FROM DISK = 'D:\db\Anya_Beliatskaya.bak';
GO