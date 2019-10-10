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
Let's add an index
======================================================*/
USE ZipCodeData;
GO


CREATE UNIQUE INDEX ix_ZipCodes_ZipCode ON dbo.ZipCodes(ZipCode);

SELECT index_id,
	index_type_desc,
	alloc_unit_type_desc,
	index_level,
	page_count,
	record_count
FROM sys.dm_db_index_physical_stats 
	(DB_ID(), OBJECT_ID('dbo.ZipCodes'), 
	(SELECT index_id FROM sys.indexes WHERE name = 'ix_ZipCodes_ZipCode'),
	NULL, 'DETAILED')
ORDER BY index_type_desc, index_level DESC;
-- 41,437 rows


/*======================================================
What kind of locks are taken?
======================================================*/

BEGIN TRAN;

SELECT ZipCode--, CityName, StateName
FROM dbo.ZipCodes;

-- Let's see what kind of locks are currently being held
SELECT resource_type, request_mode, resource_description, request_type, request_status
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID;

ROLLBACK


/*======================================================
Let's record locks in an XE session again
======================================================*/
CREATE EVENT SESSION [Locks] ON SERVER 
ADD EVENT sqlserver.lock_acquired(
    WHERE ([sqlserver].[session_id]=(55))), -- change this to current session number
-- now let's capture lock release events as well
ADD EVENT sqlserver.lock_released(
    WHERE ([sqlserver].[session_id]=(55))) -- here too!
ADD TARGET package0.ring_buffer(SET max_events_limit=(0),max_memory=(10240))
WITH (MAX_DISPATCH_LATENCY=1 SECONDS)
GO

ALTER EVENT SESSION [Locks] ON SERVER
STATE = START;

SELECT ZipCode--, CityName, StateName
FROM dbo.ZipCodes;


ALTER EVENT SESSION [Locks] ON SERVER
DROP EVENT sqlserver.lock_acquired,
DROP EVENT sqlserver.lock_released;



IF OBJECT_ID('tempdb..#xedata') IS NOT NULL
	DROP TABLE #xedata;
SELECT CAST(target_data AS XML) AS targetdata
INTO #xedata
FROM sys.dm_xe_session_targets t
JOIN sys.dm_xe_sessions s ON s.address = t.event_session_address
WHERE s.name = 'Locks'
	AND t.target_name = 'ring_buffer';

SELECT x.event_data.value('(@timestamp)[1]', 'DATETIME2') AS [timestamp],
	x.event_data.value('(@name)[1]','VARCHAR(25)') AS EventName,
	x.event_data.value('(data[@name="resource_type"]/text)[1]', 'VARCHAR(25)') AS ResourceType,
	x.event_data.value('(data[@name="mode"]/text)[1]', 'VARCHAR(25)') AS LockMode,
	DB_NAME(x.event_data.value('(data[@name="database_id"]/value)[1]', 'INT')) AS DatabaseName,
	x.event_data.value('(data[@name="resource_0"]/value)[1]', 'NVARCHAR(25)') AS Resource0,
	x.event_data.value('(data[@name="resource_1"]/value)[1]', 'NVARCHAR(25)') AS Resource1,
	x.event_data.value('(data[@name="resource_2"]/value)[1]', 'NVARCHAR(25)') AS Resource2,
	x.event_data.value('(data[@name="object_id"]/value)[1]', 'INT') AS ObjectID,
	OBJECT_NAME(x.event_data.value('(data[@name="object_id"]/value)[1]', 'INT')) AS ObjectName,
	x.event_data.value('(data[@name="associated_object_id"]/value)[1]', 'NVARCHAR(25)') AS AssociatedObjectID
FROM #xedata
CROSS APPLY targetdata.nodes('//RingBufferTarget/event') AS x (event_data)
WHERE DB_NAME(x.event_data.value('(data[@name="database_id"]/value)[1]', 'INT')) = 'ZipCodeData'
ORDER BY [timestamp],Resource0,EventName;


ALTER EVENT SESSION [Locks] ON SERVER
STATE = STOP;

DROP EVENT SESSION [Locks] ON SERVER;


/*======================================================
Read Committed games
======================================================*/

-- so now we have 41,437 zip codes. Which is first?
SELECT ZipCode
FROM dbo.ZipCodes
ORDER BY ZipCode;


-- Let's take the first Zip Code and move it to the end of the table
-- and then move it back to the beginning. Over and over again.

-- What page is our first row on?
SELECT sys.fn_PhysLocFormatter (%%physloc%%) as [File:Page:Slot],
    ZipCode
FROM dbo.ZipCodes WITH (INDEX(ix_ZipCodes_ZipCode)) 
WHERE ZipCode in ('00501')


-- Now let's change it!
UPDATE dbo.ZipCodes SET ZipCode = '99999' WHERE ZipCode = '00501';


-- Did it move?
SELECT sys.fn_PhysLocFormatter (%%physloc%%) as [File:Page:Slot],
    ZipCode
FROM dbo.ZipCodes WITH (INDEX(ix_ZipCodes_ZipCode)) 
WHERE ZipCode in ('99999')


-- And let's change it back
UPDATE dbo.ZipCodes SET ZipCode = '00501' WHERE ZipCode = '99999';

-- it move back?
SELECT sys.fn_PhysLocFormatter (%%physloc%%) as [File:Page:Slot],
    ZipCode
FROM dbo.ZipCodes WITH (INDEX(ix_ZipCodes_ZipCode)) 
WHERE ZipCode in ('00501')



-- So now we're gonna do that over and over again in another session

/*======================================================*/
SET NOCOUNT ON;
GO
UPDATE dbo.ZipCodes SET ZipCode = '99999' WHERE ZipCode = '00501';
UPDATE dbo.ZipCodes SET ZipCode = '00501' WHERE ZipCode = '99999';
GO 5000
/*======================================================*/


-- Now, in this session, let's count how many zip codes there are
-- 1,000 times.
IF OBJECT_ID('dbo.ZipCodeCounts') IS NOT NULL
	DROP TABLE dbo.ZipCodeCounts;
CREATE TABLE dbo.ZipCodeCounts (n INT);
GO

DECLARE @i INT = 1;
WHILE @i <= 1000
BEGIN
	INSERT INTO dbo.ZipCodeCounts
	SELECT COUNT(*)
	FROM dbo.ZipCodes;

	SET @i = @i + 1;
END


select * from dbo.ZipCodeCounts


SELECT n,
	count(*) as NumberOfAppearances
FROM dbo.ZipCodeCounts
GROUP BY n
ORDER BY n;
