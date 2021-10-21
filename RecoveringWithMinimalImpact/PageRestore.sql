-- Restore from Backup
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


USE [DemoData]
GO
CREATE INDEX IX_CityName
ON dbo.ZipCodes (CityName);



-- BACKUP DATABASE
BACKUP DATABASE DemoData
TO DISK = 'C:\Demos\AdvRestore\DemoData_PR.bak'
WITH COMPRESSION, CHECKSUM, INIT, FORMAT;

-- LOG BACKUP
BACKUP LOG DemoData
TO DISK = 'C:\Demos\AdvRestore\DemoData_PR1.trn'
WITH COMPRESSION, CHECKSUM, INIT, FORMAT;


-- Let's find a record
select *
from dbo.ZipCodes
where CityName = 'Hoopeston'


-- what page is it on?
select *, %%physloc%% as physloc
from dbo.ZipCodes
where CityName = 'Hoopeston'


select *
from dbo.ZipCodes
CROSS APPLY sys.fn_PhysLocCracker(%%physloc%%)
where CityName = 'Hoopeston'


-- Let's see that page!

DBCC TRACEON (3604);

DBCC PAGE ('DemoData', 3, 153, 3);




-- CORRUPT IT!!
/*

	DO NOT TRY THIS IN PRODUCTION OR IN DEV
	- IT IS NOT LOGGED
	- IT VOIDS MICROSOFT SUPPORT
	- SERIOUS INJURY OR DEATH MAY OCCUR!
	- �PISO MOJADO!

*/

ALTER DATABASE [DemoData] SET SINGLE_USER;
GO
DBCC WRITEPAGE('DemoData', 3, 153, 2560, 1, 0x4F, 1)

DBCC PAGE ('DemoData', 3, 153, 3);

ALTER DATABASE [DemoData] SET MULTI_USER;
GO

-- Let's check our dastardly deed

SELECT *
FROM dbo.ZipCodes
WHERE CityName = 'Brookfield';


SELECT *
FROM dbo.ZipCodes
WHERE CityName = 'Hoopeston';

-- RUH ROH!!!


SELECT *
FROM msdb.dbo.suspect_pages


DBCC CHECKDB (DemoData) with no_infomsgs, all_errormsgs;




-- backup log
BACKUP LOG DemoData
TO DISK = 'C:\Demos\AdvRestore\DemoData_PR2.trn'
WITH COMPRESSION, CHECKSUM, INIT, FORMAT;


-- Do a page restore
USE [master]
GO
RESTORE DATABASE DemoData
PAGE = '3:153' -- Restore just this one page
FROM DISK = 'C:\Demos\AdvRestore\DemoData_PR.bak'
WITH NORECOVERY;

-- The database is still online right now!
-- That TABLE is still online right now!
/*
-- Go to another session and run:
USE [DemoData]
GO
SELECT *
FROM dbo.ZipCodes
WHERE CityName = 'Brookfield';
*/


-- Now we need to replay the log
-- (aka restore the log backups too)
RESTORE LOG DemoData
FROM DISK = 'C:\Demos\AdvRestore\DemoData_PR1.trn'
WITH NORECOVERY;

RESTORE LOG DemoData
FROM DISK = 'C:\Demos\AdvRestore\DemoData_PR2.trn'
WITH NORECOVERY;


-- Now we need ANOTHER log backup
-- *** Most people forget this part ***
BACKUP LOG DemoData
TO DISK = 'C:\Demos\AdvRestore\DemoData_PR3.trn'
WITH COMPRESSION, CHECKSUM, INIT, FORMAT;

-- Now we restore that backup with recovery
RESTORE LOG DemoData
FROM DISK = 'C:\Demos\AdvRestore\DemoData_PR3.trn'
WITH RECOVERY;


-- Did we fix it?
USE [DemoData]
GO
SELECT *
FROM dbo.ZipCodes;

SELECT *
FROM dbo.ZipCodes
WHERE CityName = 'Hoopeston';


-- CRISIS AVERTED!!

/*
- This was an ONLINE page restore
-- Yes, this is EE only. Standard Edition gets an OFFLINE version of this

- What if we didn't have a recent full backup?

- What if we were in SIMPLE recovery model?

- What if this error happened on a nonclustered index?

*/


-- cleanup
USE [master]
GO

DROP DATABASE DemoData;
EXEC msdb.dbo.sp_delete_database_backuphistory 'DemoData'