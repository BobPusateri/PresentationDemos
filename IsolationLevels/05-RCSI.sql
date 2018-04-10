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


-- ENABLE RCSI
ALTER DATABASE ZipCodeData
SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE


/*======================================================
Are reads in RCSI repeatable?
======================================================*/
USE ZipCodeData
GO

SELECT ZipCode, CityName, StateName
FROM dbo.ZipCodes
WHERE CityName = 'Hoopeston'
-- 60942


-- In this session
-- Let's update Hoopeston's Zip Code to 99999
BEGIN TRAN

UPDATE dbo.ZipCodes
SET ZipCode = '99999'
WHERE CityName = 'Hoopeston'


-- *** In another session
BEGIN TRAN

SELECT ZipCode, CityName, StateName
FROM dbo.ZipCodes
WHERE CityName = 'Hoopeston'
-- **************************************

-- In this session
COMMIT

-- Re-run other session's query


/*======================================================
What if we move rows around?
======================================================*/
-- *** IN ANOTHER SESSION
SET NOCOUNT ON;
GO
UPDATE dbo.ZipCodes SET ZipCode = '99999' WHERE ZipCode = '00501';
UPDATE dbo.ZipCodes SET ZipCode = '00501' WHERE ZipCode = '99999';
GO 5000
/*======================================================*/

SET NOCOUNT ON;

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



