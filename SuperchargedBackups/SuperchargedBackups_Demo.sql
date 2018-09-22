BACKUP DATABASE ParkingTickets
TO DISK = 'G:\Backups\ParkingTickets.bak'
WITH INIT, FORMAT, NO_COMPRESSION;


-- INIT = overwrite all backup sets on that device
-- FORMAT = create a new media set
-- More info on media sets & backup sets: http://www.bobpusateri.com/archive/2015/11/sql-server-backup-terminology-part-1-media-sets-backup-sets-2/





-- COMPRESSION!!
BACKUP DATABASE ParkingTickets
TO DISK = 'G:\Backups\ParkingTickets_compressed.bak'
WITH INIT, FORMAT, COMPRESSION;



sp_configure 'backup compression default', 1
RECONFIGURE








-- Compression file growth
DBCC TRACEON (3042);

BACKUP DATABASE ParkingTickets
TO DISK = 'G:\Backups\ParkingTickets_compressed_incr.bak'
WITH INIT, FORMAT, COMPRESSION;

DBCC TRACEOFF (3042);








-- Striping

BACKUP DATABASE ParkingTickets
TO DISK = 'G:\Backups\ParkingTickets_1of4.bak',
DISK = 'G:\Backups\ParkingTickets_2of4.bak',
DISK = 'G:\Backups\ParkingTickets_3of4.bak',
DISK = 'G:\Backups\ParkingTickets_4of4.bak'
WITH INIT, FORMAT, COMPRESSION;


BACKUP DATABASE ParkingTickets
TO DISK = 'G:\Backups\ParkingTickets_1of10.bak',
DISK = 'G:\Backups\ParkingTickets_2of10.bak',
DISK = 'G:\Backups\ParkingTickets_3of10.bak',
DISK = 'G:\Backups\ParkingTickets_4of10.bak',
DISK = 'G:\Backups\ParkingTickets_5of10.bak',
DISK = 'G:\Backups\ParkingTickets_6of10.bak',
DISK = 'G:\Backups\ParkingTickets_7of10.bak',
DISK = 'G:\Backups\ParkingTickets_8of10.bak',
DISK = 'G:\Backups\ParkingTickets_9of10.bak',
DISK = 'G:\Backups\ParkingTickets_10of10.bak'
WITH INIT, FORMAT, COMPRESSION;



BACKUP DATABASE ParkingTickets
TO DISK = 'G:\Backups\ParkingTickets_1of18.bak',
DISK = 'G:\Backups\ParkingTickets_2of18.bak',
DISK = 'G:\Backups\ParkingTickets_3of18.bak',
DISK = 'G:\Backups\ParkingTickets_4of18.bak',
DISK = 'G:\Backups\ParkingTickets_5of18.bak',
DISK = 'G:\Backups\ParkingTickets_6of18.bak',
DISK = 'G:\Backups\ParkingTickets_7of18.bak',
DISK = 'G:\Backups\ParkingTickets_8of18.bak',
DISK = 'G:\Backups\ParkingTickets_9of18.bak',
DISK = 'G:\Backups\ParkingTickets_10of18.bak',
DISK = 'G:\Backups\ParkingTickets_11of18.bak',
DISK = 'G:\Backups\ParkingTickets_12of18.bak',
DISK = 'G:\Backups\ParkingTickets_13of18.bak',
DISK = 'G:\Backups\ParkingTickets_14of18.bak',
DISK = 'G:\Backups\ParkingTickets_15of18.bak',
DISK = 'G:\Backups\ParkingTickets_16of18.bak',
DISK = 'G:\Backups\ParkingTickets_17of18.bak',
DISK = 'G:\Backups\ParkingTickets_18of18.bak'
WITH INIT, FORMAT, COMPRESSION;




BACKUP DATABASE ParkingTickets
TO DISK = 'G:\Backups\ParkingTickets_1of52.bak',
DISK = 'G:\Backups\ParkingTickets_2of52.bak',
DISK = 'G:\Backups\ParkingTickets_3of52.bak',
DISK = 'G:\Backups\ParkingTickets_4of52.bak',
DISK = 'G:\Backups\ParkingTickets_5of52.bak',
DISK = 'G:\Backups\ParkingTickets_6of52.bak',
DISK = 'G:\Backups\ParkingTickets_7of52.bak',
DISK = 'G:\Backups\ParkingTickets_8of52.bak',
DISK = 'G:\Backups\ParkingTickets_9of52.bak',
DISK = 'G:\Backups\ParkingTickets_10of52.bak',
DISK = 'G:\Backups\ParkingTickets_11of52.bak',
DISK = 'G:\Backups\ParkingTickets_12of52.bak',
DISK = 'G:\Backups\ParkingTickets_13of52.bak',
DISK = 'G:\Backups\ParkingTickets_14of52.bak',
DISK = 'G:\Backups\ParkingTickets_15of52.bak',
DISK = 'G:\Backups\ParkingTickets_16of52.bak',
DISK = 'G:\Backups\ParkingTickets_17of52.bak',
DISK = 'G:\Backups\ParkingTickets_18of52.bak',
DISK = 'G:\Backups\ParkingTickets_19of52.bak',
DISK = 'G:\Backups\ParkingTickets_20of52.bak',
DISK = 'G:\Backups\ParkingTickets_21of52.bak',
DISK = 'G:\Backups\ParkingTickets_22of52.bak',
DISK = 'G:\Backups\ParkingTickets_23of52.bak',
DISK = 'G:\Backups\ParkingTickets_24of52.bak',
DISK = 'G:\Backups\ParkingTickets_25of52.bak',
DISK = 'G:\Backups\ParkingTickets_26of52.bak',
DISK = 'G:\Backups\ParkingTickets_27of52.bak',
DISK = 'G:\Backups\ParkingTickets_28of52.bak',
DISK = 'G:\Backups\ParkingTickets_29of52.bak',
DISK = 'G:\Backups\ParkingTickets_30of52.bak',
DISK = 'G:\Backups\ParkingTickets_31of52.bak',
DISK = 'G:\Backups\ParkingTickets_32of52.bak',
DISK = 'G:\Backups\ParkingTickets_33of52.bak',
DISK = 'G:\Backups\ParkingTickets_34of52.bak',
DISK = 'G:\Backups\ParkingTickets_35of52.bak',
DISK = 'G:\Backups\ParkingTickets_36of52.bak',
DISK = 'G:\Backups\ParkingTickets_37of52.bak',
DISK = 'G:\Backups\ParkingTickets_38of52.bak',
DISK = 'G:\Backups\ParkingTickets_39of52.bak',
DISK = 'G:\Backups\ParkingTickets_40of52.bak',
DISK = 'G:\Backups\ParkingTickets_41of52.bak',
DISK = 'G:\Backups\ParkingTickets_42of52.bak',
DISK = 'G:\Backups\ParkingTickets_43of52.bak',
DISK = 'G:\Backups\ParkingTickets_44of52.bak',
DISK = 'G:\Backups\ParkingTickets_45of52.bak',
DISK = 'G:\Backups\ParkingTickets_46of52.bak',
DISK = 'G:\Backups\ParkingTickets_47of52.bak',
DISK = 'G:\Backups\ParkingTickets_48of52.bak',
DISK = 'G:\Backups\ParkingTickets_49of52.bak',
DISK = 'G:\Backups\ParkingTickets_50of52.bak',
DISK = 'G:\Backups\ParkingTickets_51of52.bak',
DISK = 'G:\Backups\ParkingTickets_52of52.bak'
WITH INIT, FORMAT, COMPRESSION;



-- Instant File Initialization

EXEC master.dbo.sp_cycle_errorlog;

DBCC TRACEON (1806, 3004, 3605);
-- 1806 = Ignore instant file initialization even if it's enabled
-- 3004 = Capture information about zeroing
-- 3605 = Output to SQL Server error log

RESTORE DATABASE ParkingTickets_R
FROM DISK = 'C:\Backup\ParkingTickets.bak'
WITH MOVE 'ParkingTickets' TO 'F:\Data\ParkingTicketsR.mdf',
MOVE 'ParkingTickets_Data' TO 'F:\Data\ParkingTicketsR_Data.ndf',
MOVE 'ParkingTickets_Log' TO 'F:\Data\ParkingTicketsR.ldf';

DBCC TRACEOFF (1806);

DROP DATABASE ParkingTickets_R

EXEC master.dbo.sp_cycle_errorlog;

RESTORE DATABASE ParkingTickets_R
FROM DISK = 'C:\Backup\ParkingTickets.bak'
WITH MOVE 'ParkingTickets' TO 'F:\Data\ParkingTicketsR.mdf',
MOVE 'ParkingTickets_Data' TO 'F:\Data\ParkingTicketsR_Data.ndf',
MOVE 'ParkingTickets_Log' TO 'F:\Data\ParkingTicketsR.ldf';




DBCC TRACEOFF (3004, 3605);


-- What about VLFs?





-- Tuning!

-- *** DON'T DO THIS IN PRODUCTION!! ***

-- We need a benchmark!!


DBCC TRACEON (3213, 3604);
-- 3213 = Output backup buffer configuration
-- 3604 = Output to screen ("Messages" tab)


BACKUP DATABASE ParkingTickets
TO DISK = 'G:\Backups\ParkingTickets_3.bak'
WITH INIT, FORMAT, NO_COMPRESSION;



BACKUP DATABASE ParkingTickets
TO DISK = 'G:\Backups\ParkingTickets_3.bak'
WITH INIT, FORMAT, COMPRESSION;


-- Memory used in a backup
-- (BufferCount * SetsOfBuffers * MaxTransferSize)/1024

-- (7 * 3 * 1024)/1024 = (7 * 3) = 21 MB

-- this comes from OUTSIDE the buffer pool





-- NUL


BACKUP DATABASE ParkingTickets
TO DISK = 'NUL'
WITH INIT, FORMAT;


BACKUP DATABASE ParkingTickets
TO DISK = 'NUL'
WITH INIT, FORMAT,
BUFFERCOUNT = 25;


BACKUP DATABASE ParkingTickets
TO DISK = 'NUL'
WITH INIT, FORMAT,
BUFFERCOUNT = 100;


BACKUP DATABASE ParkingTickets
TO DISK = 'NUL'
WITH INIT, FORMAT,
BUFFERCOUNT = 100,
MAXTRANSFERSIZE = 4194304;


BACKUP DATABASE ParkingTickets
TO DISK = 'NUL',
DISK = 'NUL',
DISK = 'NUL',
DISK = 'NUL'
WITH INIT, FORMAT,
BUFFERCOUNT = 100,
MAXTRANSFERSIZE = 4194304;



BACKUP DATABASE ParkingTickets
TO DISK = 'G:\Backups\ParkingTickets_41.bak',
DISK = 'G:\Backups\ParkingTickets_42.bak',
DISK = 'G:\Backups\ParkingTickets_43.bak',
DISK = 'G:\Backups\ParkingTickets_44.bak'
WITH INIT, FORMAT,
BUFFERCOUNT = 100,
MAXTRANSFERSIZE = 4194304;


-- When are we done?
--   When we max out the server?



DBCC TRACEOFF (3213, 3604)


