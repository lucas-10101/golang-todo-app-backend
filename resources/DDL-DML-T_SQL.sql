/*

	Use in SQL Server
	Database: TodoApp

*/

IF NOT EXISTS(SELECT 1 FROM sys.tables WHERE Name = 'TaskOwner') BEGIN
	CREATE TABLE TaskOwner (
		Id INTEGER PRIMARY KEY CLUSTERED IDENTITY(1,1),
		Name VARCHAR(60) NOT NULL
	);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TaskItem') BEGIN
	CREATE TABLE TaskItem (
		Id INTEGER PRIMARY KEY CLUSTERED IDENTITY(1,1),
		Name VARCHAR(60) NOT NULL,
		Description VARCHAR(200),
		CreatedAt DATETIME DEFAULT GETDATE() NOT NULL,
		ClosedAt DATETIME,
		DateLimit DATETIME NOT NULL,
		OwnerId INTEGER NOT NULL FOREIGN KEY REFERENCES TaskOwner (Id)
	)
END
GO

CREATE OR ALTER VIEW Vw_TaskList AS
	SELECT 
		RANK() OVER (PARTITION BY TaskOwner.Id ORDER BY TaskItem.Id ASC) TaskNumber,
		TaskOwner.Name AS TaskOwner,
		TaskItem.Name As TaskName,
		IIF(TaskItem.ClosedAt IS NOT NULL, 1, 0) IsClosed
	FROM
		TaskOwner
		INNER JOIN TaskItem ON TaskItem.OwnerId = TaskOwner.Id

GO

DELETE FROM TaskItem;
DELETE FROM TaskOwner;

INSERT INTO TaskOwner(Name) VALUES ('Golang developer'), ('Java Developer'), ('.NET Developer');

DECLARE
	@GOLANG INT = (SELECT TOP 1 Id FROM TaskOwner WHERE Name = 'Golang developer'),
	@JAVA INT = (SELECT TOP 1 Id FROM TaskOwner WHERE Name = 'Java Developer'),
	@NET INT = (SELECT TOP 1 Id FROM TaskOwner WHERE Name = '.NET Developer');

INSERT INTO TaskItem(Name, OwnerId, Description, DateLimit) VALUES
	(CONCAT('Task ', (SELECT COUNT(Id) + 1 FROM TaskItem)), @GOLANG, NULL, DATEADD(DAY, 1, GETDATE())),
	(CONCAT('Task ', (SELECT COUNT(Id) + 1 FROM TaskItem)), @GOLANG, 'Golang second task', DATEADD(DAY, 1, GETDATE())),
	(CONCAT('Task ', (SELECT COUNT(Id) + 1 FROM TaskItem)), @GOLANG, NULL, DATEADD(DAY, 1, GETDATE())),
														 
	(CONCAT('Task ', (SELECT COUNT(Id) + 1 FROM TaskItem)), @JAVA, NULL, DATEADD(DAY, 1, GETDATE())),
	(CONCAT('Task ',  (SELECT COUNT(Id) + 1 FROM TaskItem)), @JAVA, NULL, DATEADD(DAY, 1, GETDATE())),
	(CONCAT('Task ', (SELECT COUNT(Id) + 1 FROM TaskItem)), @JAVA, 'Java third task', DATEADD(DAY, 1, GETDATE())),
														 
	(CONCAT('Task ', (SELECT COUNT(Id) + 1 FROM TaskItem)), @NET, '.NET CORE first task', DATEADD(DAY, 1, GETDATE())),
	(CONCAT('Task ', (SELECT COUNT(Id) + 1 FROM TaskItem)), @NET, NULL, DATEADD(DAY, 1, GETDATE())),
	(CONCAT('Task ', (SELECT COUNT(Id) + 1 FROM TaskItem)), @NET, NULL, DATEADD(DAY, 1, GETDATE()));

GO

SELECT * FROM Vw_TaskList