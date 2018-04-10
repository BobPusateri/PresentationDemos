/*======================================================
What's our isolation level?
======================================================*/
DBCC USEROPTIONS;


/*======================================================
Let's change it to REPEATABLE READ
======================================================*/
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

DBCC USEROPTIONS;

-- but this only affects THIS connection
-- open another connection and try



/*======================================================
Enable SNAPSHOT Isolation
======================================================*/
USE ZipCodeData
GO

ALTER DATABASE ZipCodeData SET ALLOW_SNAPSHOT_ISOLATION ON;

DBCC USEROPTIONS;

select snapshot_isolation_state_desc from sys.databases
where name = 'ZipCodeData'

SET TRANSACTION ISOLATION LEVEL SNAPSHOT;


-- What's our isolation level now?
DBCC USEROPTIONS;


ALTER DATABASE ZipCodeData SET ALLOW_SNAPSHOT_ISOLATION OFF;

/*======================================================
Enable READ COMMITTED SNAPSHOT Isolation
======================================================*/
ALTER DATABASE ZipCodeData SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE;

select snapshot_isolation_state_desc, is_read_committed_snapshot_on from sys.databases
where name = 'ZipCodeData'


-- What's our isolation level now?
DBCC USEROPTIONS;


