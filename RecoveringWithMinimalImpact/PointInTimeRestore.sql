-- Restore our demo data

USE [master]
GO

-- RESTORE DATABASE
RESTORE DATABASE DemoData
FROM DISK = 'C:\Demos\AdvRestore\DemoData.bak'
WITH REPLACE,
MOVE 'DemoData' TO 'D:\Data\DemoData.mdf',
MOVE 'ZipCodeData' TO 'D:\Data\ZipCodeData.ndf',
MOVE 'TowData' TO 'D:\Data\TowData.ndf',
MOVE 'DemoData_log' TO 'D:\Data\DemoData.ldf';



-- BACKUP DATABASE
BACKUP DATABASE DemoData
TO DISK = 'C:\Demos\AdvRestore\DemoData_PITFull.bak'
WITH COMPRESSION, CHECKSUM, INIT, FORMAT;

-- LOG BACKUP
BACKUP LOG DemoData
TO DISK = 'C:\Demos\AdvRestore\DemoData_PIT1.trn'
WITH COMPRESSION, CHECKSUM, INIT, FORMAT;




USE [DemoData]
GO

SELECT *
FROM dbo.ZipCodes;

SELECT ZipCode, CityName, StateName
FROM dbo.ZipCodes
WHERE CityName = 'Brookfield'
ORDER BY StateName;


-- Let's change it!
UPDATE dbo.ZipCodes
SET ZipCode = '00000'
WHERE CityName = 'Brookfield'
AND StateName = 'IL';

DELETE
FROM dbo.ZipCodes
WHERE ZipCode = '60515';
SELECT GETDATE(); -- 

-- Let's mess up!
UPDATE dbo.ZipCodes
SET StateName = 'WA'
SELECT GETDATE(); -- 


SELECT *
FROM dbo.ZipCodes;

-- log backup
BACKUP LOG DemoData
TO DISK = 'C:\Demos\AdvRestore\DemoData_PIT2.trn'
WITH COMPRESSION, CHECKSUM, INIT, FORMAT;


-- Now let's restore
RESTORE FILELISTONLY
FROM DISK = 'C:\Demos\AdvRestore\DemoData_PITFull.bak';

DROP DATABASE DemoData_Restored;

RESTORE DATABASE DemoData_Restored
FROM DISK = 'C:\Demos\AdvRestore\DemoData_PITFull.bak'
WITH NORECOVERY,
MOVE 'DemoData' TO 'D:\Data\DemoData-Restored.mdf',
MOVE 'DemoData_log' TO 'D:\Data\DemoData-Restored.ldf',
MOVE 'ZipCodeData' TO 'D:\Data\Demo_ZipCodeData-Restored.ndf',
MOVE 'TowData' TO 'D:\Data\Demo_TowData-Restored.ndf';

RESTORE LOG DemoData_Restored
FROM DISK = 'C:\Demos\AdvRestore\DemoData_PIT1.trn'
WITH NORECOVERY;

-- RESTORE LOG with STOPAT
RESTORE LOG DemoData_Restored
FROM DISK = 'C:\Demos\AdvRestore\DemoData_PIT2.trn'
WITH NORECOVERY,
STOPAT = '2020-10-26 15:54:57.650';


-- Recover
RESTORE DATABASE DemoData_Restored WITH RECOVERY;

--Backup Database
BACKUP DATABASE DemoData_Restored
TO DISK = 'C:\Demos\AdvRestore\DemoDataRestored_PITFull.bak'
WITH COMPRESSION, CHECKSUM, INIT, FORMAT;

-- Backup Log
BACKUP LOG DemoData_Restored
TO DISK = 'C:\Demos\AdvRestore\DemoDataRestored_PIT.trn'
WITH COMPRESSION, CHECKSUM, INIT, FORMAT;

-- now let's query
USE [DemoData_Restored]
GO

SELECT *
FROM dbo.ZipCodes;

SELECT *
FROM dbo.ZipCodes
WHERE ZipCode = '60515'




-- == MARKED TRANSACTIONS ==

USE [DemoData_Restored]
GO

BEGIN TRAN UpdateState -- transaction name
WITH MARK 'description_can_go_here' -- description is optional, "WITH MARK" is not

UPDATE dbo.ZipCodes
SET StateName = 'IL', ZipCode = '60513'
WHERE ZipCode = '00000';

COMMIT TRANSACTION UpdateState -- restate transaction name

-- let's do another unmarked transaction
UPDATE dbo.ZipCodes
SET StateName = 'OR'
WHERE StateName = 'WA';

-- Backup Log
BACKUP LOG DemoData_Restored
TO DISK = 'C:\Demos\AdvRestore\DemoDataRestored_PIT2.trn'
WITH COMPRESSION, CHECKSUM, INIT, FORMAT;


-- Restore
RESTORE DATABASE DemoData_Restored2
FROM DISK = 'C:\Demos\AdvRestore\DemoDataRestored_PITFull.bak'
WITH NORECOVERY,
MOVE 'DemoData' TO 'D:\Data\DemoData-Restored2.mdf',
MOVE 'DemoData_log' TO 'D:\Data\DemoData-Restored2.ldf',
MOVE 'ZipCodeData' TO 'D:\Data\Demo_ZipCodeData-Restored2.ndf',
MOVE 'TowData' TO 'D:\Data\Demo_TowData-Restored2.ndf';

RESTORE LOG DemoData_Restored2
FROM DISK = 'C:\Demos\AdvRestore\DemoDataRestored_PIT.trn'
WITH NORECOVERY;

RESTORE LOG DemoData_Restored2
FROM DISK = 'C:\Demos\AdvRestore\DemoDataRestored_PIT2.trn'
WITH NORECOVERY,
STOPATMARK = 'UpdateState';-- apply all transactions UP TO AND INCLUDING this named transaction


RESTORE DATABASE DemoData_Restored2
WITH RECOVERY;

USE [DemoData_Restored2]
GO

SELECT *
FROM dbo.ZipCodes;

SELECT *
FROM dbo.ZipCodes
WHERE ZipCode = '60513'

-- See a list of all marked transactions
SELECT * FROM msdb.dbo.logmarkhistory;



-- Cleanup, Aisle 2
USE [master]
GO

DROP DATABASE DemoData;
DROP DATABASE DemoData_Restored;
DROP DATABASE DemoData_Restored2;
EXEC msdb.dbo.sp_delete_database_backuphistory 'DemoData'

