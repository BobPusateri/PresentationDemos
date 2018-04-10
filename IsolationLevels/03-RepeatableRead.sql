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
Row-Locking Behavior
======================================================*/
USE ZipCodeData;
GO

BEGIN TRAN;

SELECT ZipCode, CityName, StateName
FROM dbo.ZipCodes WITH (REPEATABLEREAD)
WHERE StateName = 'IL'
AND CityName LIKE 'A%';


SELECT resource_type, request_mode, resource_description, request_type, request_status
FROM sys.dm_tran_locks
WHERE request_session_id = @@spid;

ROLLBACK


/*======================================================
How about the switching game?
======================================================*/

-- *** IN ANOTHER SESSION
SET NOCOUNT ON;
GO
UPDATE dbo.ZipCodes SET ZipCode = '99999' WHERE ZipCode = '00501';
UPDATE dbo.ZipCodes SET ZipCode = '00501' WHERE ZipCode = '99999';
GO 5000
/*======================================================*/

SET NOCOUNT ON;

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

-- Now, in this session, let's count how many zip codes
-- 10,000 times.
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


SELECT n,
	count(*) as NumberOfAppearances
FROM dbo.ZipCodeCounts
GROUP BY n
ORDER BY n;


/*======================================================
Phantom Rows: Still Possible!
======================================================*/
USE ZipCodeData;
GO


SET TRANSACTION ISOLATION LEVEL REPEATABLE READ

BEGIN TRAN
SELECT ZipCode, CityName, StateName
FROM dbo.ZipCodes
WHERE StateName = 'IL'
AND CityName LIKE 'A%'
ORDER BY CityName;


-- *** in another session
INSERT INTO dbo.ZipCodes (ZipCode, CityName, StateName)
VALUES ('62602','Abingdon 2','IL')
-- **************************************


SELECT ZipCode, CityName, StateName
FROM dbo.ZipCodes
WHERE StateName = 'IL'
AND CityName LIKE 'A%'
ORDER BY CityName;


COMMIT

