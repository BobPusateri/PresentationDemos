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
FROM DISK = 'C:\Demos\Isolation\ZipCodeData.bak'
WITH REPLACE, CHECKSUM;



/*======================================================
What's our data like?
======================================================*/
USE ZipCodeData;
GO

SELECT * FROM dbo.ZipCodes ORDER BY ZipCode;


-- Let's see how many U.S. cities are named Paris
SELECT ZipCode, CityName, StateName
FROM dbo.ZipCodes
WHERE CityName = 'Paris'
ORDER BY ZipCode;


/*======================================================
Dirty reads in action
======================================================*/

-- in this session, run
BEGIN TRAN
UPDATE dbo.ZipCodes SET CityName = 'Bob';


-- *** IN ANOTHER SESSION, RUN
SELECT * FROM dbo.ZipCodes WITH (NOLOCK);
-- ****************************

-- ROLLBACK;


/*======================================================
No Locks? Hogwash!
======================================================*/
-- create an XE session to look for locks
CREATE EVENT SESSION [Locks] ON SERVER 
ADD EVENT sqlserver.lock_acquired(
    WHERE ([sqlserver].[session_id]=(55))) -- update to current session number
ADD TARGET package0.ring_buffer(SET max_events_limit=(0),max_memory=(10240))
WITH (MAX_DISPATCH_LATENCY=1 SECONDS)
GO

ALTER EVENT SESSION [Locks] ON SERVER
STATE = START;


-- Now, in this session, run:
SELECT * FROM dbo.ZipCodes WITH (NOLOCK);

ALTER EVENT SESSION [Locks] ON SERVER
DROP EVENT sqlserver.lock_acquired;



IF OBJECT_ID('tempdb..#xedata') IS NOT NULL
	DROP TABLE #xedata;
SELECT CAST(target_data AS XML) AS targetdata
INTO #xedata
FROM sys.dm_xe_session_targets t
JOIN sys.dm_xe_sessions s ON s.address = t.event_session_address
WHERE s.name = 'Locks'
	AND t.target_name = 'ring_buffer';

SELECT x.event_data.value('(@timestamp)[1]', 'DATETIME2') AS [timestamp],
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
WHERE DB_NAME(x.event_data.value('(data[@name="database_id"]/value)[1]', 'INT')) = 'ZipCodeData';









ALTER EVENT SESSION [Locks] ON SERVER
STATE = STOP;

DROP EVENT SESSION [Locks] ON SERVER;
