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


-- Allow Snapshot
ALTER DATABASE ZipCodeData
SET ALLOW_SNAPSHOT_ISOLATION ON;

USE ZipCodeData;
GO

-- Enable Snapshot
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;


/*======================================================
Let's try the RCSI example again, this time in snapshot
======================================================*/
-- In this session
-- Let's update Hoopeston's Zip Code to 99999
BEGIN TRAN
UPDATE dbo.ZipCodes
SET ZipCode = '99999'
WHERE CityName = 'Hoopeston'


-- *** In another session
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

BEGIN TRAN

SELECT ZipCode, CityName, StateName
FROM dbo.ZipCodes
WHERE CityName = 'Hoopeston'
-- **************************************

-- In this session
COMMIT TRAN

SELECT ZipCode, CityName, StateName
FROM dbo.ZipCodes
WHERE CityName = 'Hoopeston'


-- *** In another session
SELECT ZipCode, CityName, StateName
FROM dbo.ZipCodes
WHERE CityName = 'Hoopeston'

COMMIT TRAN

SELECT ZipCode, CityName, StateName
FROM dbo.ZipCodes
WHERE CityName = 'Hoopeston'
-- **************************************



/*======================================================
Snapshot update conflicts
======================================================*/
BEGIN TRAN

SELECT ZipCode, CityName, StateName
FROM dbo.ZipCodes
WHERE CityName = 'Riverside' AND StateName = 'IL'


-- *** In another session
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

BEGIN TRAN

UPDATE dbo.ZipCodes
SET ZipCode = '99998'
WHERE CityName = 'Riverside' AND StateName = 'IL'
-- **************************************

-- in this session
UPDATE dbo.ZipCodes
SET ZipCode = '77777'
WHERE CityName = 'Riverside' AND StateName = 'IL'
-- this will block!

-- *** In another session
COMMIT TRAN
-- **************************************


