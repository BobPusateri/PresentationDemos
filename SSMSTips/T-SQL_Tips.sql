/*
	Helpful T-SQL Scripts

	If I keep referring to these, chances are good
	that other people might benefit as well!

	The demo database this code utilizes is the Chicago Parking Ticket Database
	
	https://www.bobpusateri.com/archive/2018/09/new-data-set-chicago-parking-tickets/

	Database download (~500MB): 
	https://www.bobpusateri.com/r/parking-tickets


*/




USE [ParkingTickets]
GO



/*
	1.
	Comma-Separated Output
*/



SELECT TOP (10) car_make
FROM dbo.Ticket;

-- we want them in a comma-delimited list

-- FOR XML PATH('')
SELECT TOP (10) car_make
FROM dbo.Ticket
FOR XML PATH('');



-- Let's add a delimeter
SELECT TOP (10) ',' + car_make
FROM dbo.Ticket
FOR XML PATH('');



-- And now we just remove the leading comma

-- SUBSTRING(expression, start, length)
-- SUBSTRING() on its own would require knowing the length of the string
-- Can substitute a large value, but if actual results exceed that we've got a problem

SELECT
	SUBSTRING(
		(
			SELECT TOP (10) ',' + car_make
			FROM dbo.Ticket
			FOR XML PATH('')
		), 2, 10000
	) AS Substr;



-- Let's try STUFF()!

-- STUFF(character_expression, start, length, replaceWith_expression)  
-- Deletes a specified length of characters in the first string,
-- at the start position, 
-- then inserts the second string into the first string,
-- at the start position.

SELECT 
	'ABCDEFG' AS OriginalValue,
	STUFF(
		'ABCDEFG',	-- starting string
		3,			-- start position
		2,			-- number of characters to replace
		'000'		-- replacement string
	) AS StuffValue;


-- We can use STUFF() as a left truncate
SELECT
	',Willis,Lucy' AS OriginalValue,
	STUFF(
		',Willis,Lucy',	-- Start Value
		1,				-- Start Position
		1,				-- characters to replace
		''				-- replacement (empty string)
	) AS ExampleResult;


-- Back to our example
SELECT STUFF (
	(
		SELECT TOP (10) ',' + car_make
		FROM dbo.Ticket
		FOR XML PATH('')
	), 1, 1, ''
) AS CarMakeList;




-- What if we wanted to do grouping?
-- Get a list of hearing dispositions by car make

SELECT DISTINCT car_make, hearing_disposition
into #makehearing
from dbo.vw_ParkingTickets;

SELECT * FROM #makehearing;


SELECT 
	mh.car_make,
	STUFF(
			(SELECT ',' + mh2.hearing_disposition
			FROM #makehearing AS mh2
			WHERE mh.car_make = mh2.car_make	-- this is a correlated subquery
			ORDER BY mh2.hearing_disposition
			FOR XML PATH('')
		), 1, 1, ''
	) AS HearingDispositions 
FROM #makehearing mh
GROUP BY mh.car_make
ORDER BY mh.car_make;







/*
	2.
	Insert only new values into a key table
*/

CREATE TABLE dbo.BadgeList (
	BadgeID INT IDENTITY(1,1) PRIMARY KEY,
	BadgeNum CHAR(6) NOT NULL
);

-- insert an initial batch
INSERT INTO dbo.BadgeList(BadgeNum)
SELECT DISTINCT LTRIM(RTRIM(t.badge))
FROM dbo.Ticket t
LEFT JOIN dbo.BadgeList bl ON LTRIM(RTRIM(t.badge)) = bl.BadgeNum
WHERE t.ticket_number < 1000000
	AND bl.BadgeID IS NULL
	AND LTRIM(RTRIM(t.badge)) <> '';


-- insert a second batch
INSERT INTO dbo.BadgeList(BadgeNum)
SELECT DISTINCT LTRIM(RTRIM(t.badge))
FROM dbo.Ticket t
LEFT JOIN dbo.BadgeList bl ON LTRIM(RTRIM(t.badge)) = bl.BadgeNum
WHERE t.ticket_number >= 1000000 and t.ticket_number < 3000000
	AND bl.BadgeID IS NULL
	AND LTRIM(RTRIM(t.badge)) <> '';


SELECT * FROM dbo.BadgeList;


DROP TABLE dbo.BadgeList;













/*
	3.
	Kill users blocking critical processes at certain times
*/

-- sp_whoisactive - use it!
-- http://whoisactive.com/

*/





CREATE PROCEDURE [dbo].[BlockHandler]
AS

SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#s') IS NOT NULL
      DROP TABLE #s

CREATE TABLE #s ( 
	[dd hh:mm:ss.mss] varchar(30) NULL,
	[session_id] smallint NOT NULL,
	[sql_text] xml NULL,
	[login_name] nvarchar(128) NOT NULL,
	[blocking_session_id] smallint NULL,
	[blocked_session_count] varchar(30) NULL,
	[host_name] nvarchar(128) NULL,
	[database_name] nvarchar(128) NULL,
	[program_name] nvarchar(128) NULL,
	[start_time] datetime NOT NULL,
	[login_time] datetime NULL
)

EXEC sp_whoisactive 
      @destination_table = '#s',
	  @find_block_leaders=1,
      @output_column_list = '[dd%][session_id][sql_text][login_name][blocking_session_id][blocked_session_count][host_name][database_name][program_name][start_time][login_time]'


SELECT
	ROW_NUMBER() OVER(ORDER BY blocker.session_id) AS [RowNum],
	CONVERT(BIT,0) AS processed,
	LTRIM(RTRIM(blocker.[dd hh:mm:ss.mss])) AS BlockerRunTime,
	blocker.[session_id] AS BlockerSessionID,
	blocker.[sql_text] AS BlockerSQL,
	blocker.[login_name] AS BlockerLogin,
	blocker.[blocked_session_count] AS BlockerBlockCount,
	blocker.[host_name] AS BlockerHostName,
	blocker.[database_name] AS BlockerDBName,
	blocker.[program_name] AS BlockerProgramName,
	blocker.[start_time] AS BlockerStartTime,
	blocker.[login_time] AS BlockerLoginTime,
	LTRIM(RTRIM(blockee.[dd hh:mm:ss.mss])) AS BlockeeRunTime,
	blockee.[session_id] AS BlockeeSessionID,
	blockee.[sql_text] AS BlockeeSQL,
	blockee.[login_name] AS BlockeeLogin,
	blockee.[host_name] AS BlockeeHostName,
	blockee.[database_name] AS BlockeeDBName,
	blockee.[program_name] AS BlockeeProgramName,
	blockee.[start_time] AS BlockeeStartTime,
	blockee.[login_time] AS BlockeeLoginTime
INTO #KillList
FROM #s blocker
INNER JOIN #s blockee ON blockee.[blocking_session_id] = blocker.[session_id]
WHERE blocker.[blocked_session_count] > 0
	AND blocker.[blocking_session_id] IS NULL
	AND blocker.[login_name] <> blockee.[login_name]
	AND blockee.[login_name] IN (
		-- users that should win
		'CompanyDomain\JobRunner',
		'ETLUser'
	)
	AND blocker.[login_name] NOT IN (
		-- users that can block
		'CompanyDomain\OkToBlock',
		'OtherETLUser'
	);

DECLARE @dt DATETIME2(0);
SET @dt = SYSDATETIME();

-- log into table
IF EXISTS (SELECT * FROM #KillList)
BEGIN
	INSERT INTO UtilityDB.dbo.KilledSPIDLog ([EventTime], [dd hh:mm:ss.mss], [session_id], [sql_text], [login_name],
		[blocking_session_id], [blocked_session_count], [host_name], [database_name], [program_name], [start_time], [login_time])
	SELECT @dt, *
	FROM #s;
END

DECLARE @KillIdx INT;
DECLARE @DoKill BIT;
DECLARE @KillSPID SMALLINT;
DECLARE @KillCmd nvarchar(100);

SET @KillCmd = 'KILL ';

-- only kill between 7pm and 8am
IF(CONVERT(TIME, @dt) >= '19:00' OR CONVERT(TIME, @dt) < '08:00')
	SET @DoKill = 1;
ELSE
	SET @DoKill = 0;


WHILE EXISTS (SELECT * FROM #KillList WHERE processed = 0)
BEGIN
	SELECT TOP(1) @KillIdx = [RowNum] FROM #KillList WHERE processed = 0 ORDER BY [RowNum];
	
	SELECT *
	INTO ##KillRow
	FROM #KillList
	WHERE [RowNum] = @KillIdx;
	
	-- kill
	IF(@DoKill = 1)
	BEGIN
	
		-- kill the spid
		SET @KillSPID = (SELECT BlockerSessionID FROM ##KillRow);
		SET @KillCmd = @KillCmd + CONVERT(NVARCHAR(5), @KillSPID) + ';';
		EXEC sp_executesql @KillCmd;
	
		-- mark spid as killed in table
		UPDATE ksl
		SET KilledSPID = 1
		FROM UtilityDB.dbo.KilledSPIDLog ksl
		INNER JOIN ##KillRow kr ON ksl.session_id = kr.BlockerSessionID
		WHERE ksl.EventTime = @dt
	
	END
	
	
	-- send email
	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'EmailProfile',
		@recipients = 'Recipients@Company.org',
		@subject = 'SPID Killer Activity',
		@body = 'The following processes were killed',
		@execute_query_database = 'master',
		@query = 'SELECT * from ##KillRow';

	--DELETE FROM #KillList WHERE [RowNum] = @KillIdx;
	UPDATE #KillList SET processed = 1 WHERE [RowNum] = @KillIdx;
	
	DROP TABLE ##KillRow;
END -- while loop

DROP TABLE #KillList;

















/*
	4.
	Did you know you could name databases with emoji?
*/
CREATE DATABASE [🐈];



