-- RESTORE DATABASE
USE [master]
GO
RESTORE DATABASE DemoData
FROM DISK = 'C:\Demos\AdvRestore\DemoData.bak'
WITH REPLACE,
MOVE 'DemoData' TO 'D:\Data\DemoData.mdf',
MOVE 'ZipCodeData' TO 'D:\Data\ZipCodeData.ndf',
MOVE 'TowData' TO 'D:\Data\TowData.ndf',
MOVE 'DemoData_log' TO 'D:\Data\DemoData.ldf';


-- BACKUP DATABASE
BACKUP DATABASE DemoData
TO DISK = 'C:\Demos\AdvRestore\DemoData_PMFull.bak'
WITH COMPRESSION, CHECKSUM, INIT, FORMAT;


-- Let's add a record
USE [DemoData]
GO
INSERT INTO dbo.TowedVehicles (ID, TowDate, Make, Style, Color, Plate, [State])
VALUES (9999999, '20201021','SUBA','4D','BLU','SQLSRVR','IL');


-- LOG BACKUP
BACKUP LOG DemoData
TO DISK = 'C:\Demos\AdvRestore\DemoData_PM1.trn'
WITH COMPRESSION, CHECKSUM, INIT, FORMAT;


-- Let's add another record
INSERT INTO dbo.TowedVehicles (ID, TowDate, Make, Style, Color, Plate, [State])
VALUES (9999998, '20180111','MERC','4D','TAN','ORCLSUX','IL');


BACKUP LOG DemoData
TO DISK = 'C:\Demos\AdvRestore\DemoData_PM2.trn'
WITH COMPRESSION, CHECKSUM, INIT, FORMAT;



-- How are our filegroups setup?
USE [DemoData]
GO	
SELECT *
FROM sys.filegroups;


-- What are the file name(s) for each filegroup?
SELECT 
	fg.name as FilegroupName, 
	f.name as FileName,
	f.physical_name as FilePath
FROM sys.database_files f
INNER JOIN sys.filegroups fg ON fg.data_space_id = f.data_space_id; 

-- What Objects in each filegroup?
SELECT 
	o.name AS ObjectName,
	p.index_id AS IndexID,
	f.name AS FilegroupName	
FROM sys.filegroups f
	INNER JOIN sys.allocation_units a ON a.data_space_id = f.data_space_id
	INNER JOIN sys.partitions p ON p.partition_id = a.container_id 
	INNER JOIN sys.objects o ON o.object_id = p.object_id
WHERE o.type_desc NOT IN ('SYSTEM_TABLE', 'INTERNAL_TABLE')
ORDER BY ObjectName, IndexID;


-- Let's drop the database (DISASTER!!)
USE [master]
GO
DROP DATABASE DemoData;




-- Now let's do a partial restore
-- Restoring the Tow_Data filegroup
-- First restore MUST include the primary filegroup
RESTORE DATABASE DemoData
FILEGROUP='Primary' 
FROM DISK = 'C:\Demos\AdvRestore\DemoData_PMFull.bak'
WITH PARTIAL, NORECOVERY;

RESTORE DATABASE DemoData
FILEGROUP='Tow_Data' 
FROM DISK = 'C:\Demos\AdvRestore\DemoData_PMFull.bak'
WITH PARTIAL, NORECOVERY;

RESTORE LOG DemoData
FROM DISK = 'C:\Demos\AdvRestore\DemoData_PM1.trn'
WITH NORECOVERY;

RESTORE LOG DemoData
FROM DISK = 'C:\Demos\AdvRestore\DemoData_PM2.trn'
WITH NORECOVERY;

RESTORE DATABASE DemoData
WITH RECOVERY;


-- At this point, the Tow_Data filegroup is online
USE [DemoData]
GO
SELECT * 
FROM dbo.TowedVehicles
WHERE Plate = 'SQLSRVR';


-- ZipCode_Data is not online yet
SELECT TOP (10) *
FROM dbo.ZipCodes;


-- Now let's bring ZipCode_Data online
USE [master]
GO
RESTORE DATABASE DemoData
FILEGROUP='ZipCode_Data' 
FROM DISK = 'C:\Demos\AdvRestore\DemoData_PMFull.bak'
WITH NORECOVERY;

-- Now we need to apply ALL transaction logs to bring this FG up to date
RESTORE LOG DemoData
FROM DISK = 'C:\Demos\AdvRestore\DemoData_PM1.trn'
WITH NORECOVERY;

RESTORE LOG DemoData
FROM DISK = 'C:\Demos\AdvRestore\DemoData_PM2.trn'
WITH NORECOVERY;

RESTORE DATABASE DemoData
WITH RECOVERY;

-- Now Test ZipCodes
USE [DemoData]
GO
SELECT TOP (10) *
FROM dbo.ZipCodes;




-- cleanup
USE [master]
GO

DROP DATABASE DemoData;
EXEC msdb.dbo.sp_delete_database_backuphistory 'DemoData'
