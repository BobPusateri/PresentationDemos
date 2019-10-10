/*======================================================
Restore our database
======================================================*/
USE master;
GO

IF DB_ID('ZipCodeData') IS NOT NULL
BEGIN
	ALTER DATABASE ZipCodeData
		SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
END
GO

RESTORE DATABASE ZipCodeData
FROM DISK = '/var/opt/mssql/backup/ZipCodeData2.bak'
WITH MOVE 'ZipCodes' TO '/var/opt/mssql/data/ZipCodeData.mdf',
MOVE 'ZipCodes_log' TO '/var/opt/mssql/log/ZipCodeData.ldf',
REPLACE;


/*======================================================
Row-Locking Behavior
======================================================*/
USE ZipCodeData;
GO

CREATE UNIQUE INDEX IX_ZipCode 
ON dbo.ZipCodes (ZipCode)

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRAN;

SELECT ZipCode, CityName, StateName
FROM dbo.ZipCodes
WHERE ZipCode LIKE '1051%'


SELECT l.resource_type, l.request_mode, l.resource_description, l.request_type, l.request_status,
	OBJECT_NAME(i.object_id) AS ObjectName, i.index_id, i.name AS IndexName, i.type_desc
FROM sys.dm_tran_locks l
LEFT JOIN sys.partitions p ON p.partition_id = l.resource_associated_entity_id
LEFT JOIN sys.indexes i ON i.object_id = p.object_id AND i.index_id = p.index_id
WHERE request_session_id = @@spid
	AND resource_type = 'KEY'
ORDER BY resource_type, request_mode;



ROLLBACK
