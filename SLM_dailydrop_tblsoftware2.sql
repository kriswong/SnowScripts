/*********
Transformed the original Script by Oliver Berger in to a stored procedure
so that it can be called by the DUJ in the Pre/Post Custom Procedures.
This procedures only affect the SLM database but will not affect the 
DataApplications within SnowInventory where they originate.

NOte this procedure even when it does NO Cleaning will Add ~10-12 min to
Your DUJ. So if the tblsoftware does not need to be cleaned then avoid this.

Modified by Kris Wong
Date:2020/12/22
*********/
/*
Script to remove orphaned tblsoftware lines.
works best with (relatively) small amounts of lines to remove.
If you have a relatively small number of rows to keep, check the bigwipe scripts.
Adjust @softwareRage, @deleteBatchsize, @maxruntime acording to your experience.
Use the orphanedSoftwareLicenseManager script to check success.
https://gist.github.com/snowliver/c9766c4ea3ba8c2c702d29a1ce6dfdd8

make sure you uses the latest version of this script.
https://gist.github.com/snowliver/5532d6a4b3378a5a8cf5a8c5e04efdb2
Cheers oliver.berger@snowsoftware.com
*/

/* Have a nice read about indexes
--https://www.beyondtrust.com/docs/privileged-identity/faqs/reorganize-and-rebuild-indexes-in-database.htm
used tables:
- dbo.tblsoftware
- dbo.tblComputerSoftware
- dbo.tblComputerSoftwareInstalled 
- dbo.tblComputerOperatingSystem 
- dbo.tblMetering
- dbo.tblWebAppMetering

nice stats:
select a.object_id, b.name,a.index_id,a.index_type_desc,a.avg_fragmentation_in_percent,a.fragment_count, a.avg_fragment_size_in_pages
from sys.dm_db_index_physical_stats (db_id(), object_id ('tblsoftware'), default, default, default) as a
JOIN sys.indexes AS b
ON a.object_id = b.object_id AND a.index_id = b.index_id;

Alter index all on tblsoftware rebuild with (online = on)
Alter index all on tblComputerSoftware rebuild with (online = on)
Alter index all on tblComputerSoftwareInstalled rebuild with (online = on)
Alter index all on tblComputerOperatingSystem rebuild with (online = on)
Alter index all on tblMetering rebuild with (online = on)
Alter index all on tblWebAppMetering rebuild with (online = on)

*/
USE SnowLicenseManager
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[_Clean_TblSoftware]
(
	@softwareRange INT, 	-- 100000 for locality in joins (recommended 100K - 1M)
	@deleteBatchsize INT, 	-- 10000 size of individual batched deletes. (recommended 1-100K. pick a lower number in smaller environments or on HDD storage)
	@maxRunTimeMins INT 	-- 60 how many minutes max the cleanup should run each day.
)
AS
BEGIN
	SET NOCOUNT ON;
-- Create & Set Variables
	declare @msg nvarchar(max), @number int
	declare @minChecksum BIGINT = power(-convert(bigint,2),63)
	declare @maxChecksum BIGINT = @minchecksum -- needs to be small for the start
	declare @deletedtotal int = 0
	declare @deleted INT = 0
	declare @iterations int = 0
	declare @startdate datetime = getdate();
	declare @dcount int = 0
	declare @endDateTime datetime = DATEADD(MINUTE, @maxRunTimeMins, GETDATE());
	
	set @msg = '(' + format(getdate(),'s') + '): starting tblsoftware cleanup'
	raiserror (@msg, 0, 1) with nowait

	if object_id('tempdb..#todelete') is not null
		Begin
			set @msg = '(' + format(getdate(),'s') + '): remove existing temp table'
			raiserror (@msg, 0, 1) with nowait
			DROP TABLE #todelete
		end

	set @msg = '(' + format(getdate(),'s') + '): Disable indexes on SnowLicenseManager.dbo.tblSoftware to speed up deletion'
	raiserror (@msg, 0, 1) with nowait
	alter index all on SnowLicenseManager.dbo.tblSoftware disable

	set @msg = '(' + format(getdate(),'s') + '): Rebuild PK index on SnowLicenseManager.dbo.tblSoftware to speed up deletion'
	raiserror (@msg, 0, 1) with nowait
	alter index PK_tblSoftware on SnowLicenseManager.dbo.tblSoftware rebuild

	CREATE TABLE #toDelete([SoftwareCheckSum] BIGINT PRIMARY key)

	while (getdate() < @endDateTime)
	Begin
		set @iterations +=1
		;WITH cte AS 
			(
			SELECT TOP (@softwareRange) [s].[SoftwareCheckSum]
			FROM [dbo].[tblSoftware] AS [s]
			WHERE s.[SoftwareCheckSum] >= @maxChecksum
			ORDER BY [s].[SoftwareCheckSum]
		)
		 
		 --set range for next round of cleanup
		SELECT @minChecksum = MIN([c].[SoftwareCheckSum])
		, @maxChecksum = MAX([c].[SoftwareCheckSum])
		FROM cte c

		if @minChecksum = @maxChecksum
			Begin
				set @msg = '(' + format(getdate(),'s') + '): Iteration ' + convert(nvarchar(20),@iterations) + ' reached the end of checksums'
				raiserror (@msg, 0, 1) with nowait
				BREAK;
			end

		set @msg = '(' + format(getdate(),'s') + '): Iteration ' + convert(nvarchar(20),@iterations) + ' between checksums ' + convert(nvarchar(21),@minchecksum) + ' and ' + convert(nvarchar(21),@maxchecksum) + '.'
		raiserror (@msg, 0, 1) with nowait

		INSERT INTO [#toDelete] WITH(tablockx)([SoftwareCheckSum])
			SELECT s.[SoftwareCheckSum]
			FROM [dbo].[tblSoftware] AS [s]
			WHERE s.[SoftwareCheckSum] BETWEEN @minChecksum AND @maxChecksum --using this BETWEEN limits the JOINS to the same range of keys in the other table(s)
			AND NOT EXISTS (SELECT 0/0 FROM dbo.tblComputerSoftware x WHERE x.[SoftwareCheckSum] = s.[SoftwareCheckSum])
			AND NOT EXISTS (SELECT 0/0 FROM dbo.tblComputerSoftwareInstalled x WHERE x.[SoftwareCheckSum] = s.[SoftwareCheckSum])
			AND NOT EXISTS (SELECT 0/0 FROM dbo.tblComputerOperatingSystem x WHERE x.[SoftwareCheckSum] = s.[SoftwareCheckSum])
			AND NOT EXISTS (SELECT 0/0 FROM dbo.tblMetering x WHERE x.[SoftwareCheckSum] = s.[SoftwareCheckSum])
			AND NOT EXISTS (SELECT 0/0 FROM dbo.tblWebAppMetering x WHERE x.[SoftwareCheckSum] = s.[SoftwareCheckSum])
		
		set @dcount = @@ROWCOUNT
		set @msg = '(' + format(getdate(),'s') + '): Iteration ' + convert(nvarchar(20),@iterations) + ' filled #todelete with ' + convert(nvarchar(20),@dcount) + ' lines.' 
		raiserror (@msg, 0, 1) with nowait

		if (GETDATE() > @endDateTime)
		Begin
			set @msg = '(' + format(getdate(),'s') + '): Iteration ' + convert(nvarchar(20),@iterations) + ' Reached timeout.' 
			raiserror (@msg, 0, 1) with nowait
			BREAK;
		end

		if (@dcount = 0)
		Begin
			set @msg = '(' + format(getdate(),'s') + '): Iteration ' + convert(nvarchar(20),@iterations) + ' No items to delete.' 
			raiserror (@msg, 0, 1) with nowait
			BREAK;
		end
		
		set @deleted = @deleteBatchsize --preset @deleted to enter the while
		while (@deleted = @deleteBatchsize and getdate() < @endDateTime)
		BEGIN
			delete top (@deleteBatchsize) s
				from tblSoftware s
				where exists (select 1 from #todelete t where t.SoftwareCheckSum = s.SoftwareCheckSum)
				and s.[SoftwareCheckSum] BETWEEN @minChecksum AND @maxChecksum

			SET @deleted = @@ROWCOUNT
			SET @deletedtotal += @deleted
			
			set @minChecksum = (Select s.softwarechecksum from #todelete s
				order by s.SoftwareCheckSum
				OFFSET @deleted ROWS
				Fetch next 1 rows only)
		END
		
		truncate table #todelete
		set @msg = '(' + format(getdate(),'s') + '): Iteration ' + convert(nvarchar(20),@iterations) +' Deleted ' + convert(nvarchar(20),@deletedtotal) + ' lines in ' + convert(nvarchar(20),datediff(second,@startdate,Getdate())) + ' seconds after ' + convert(nvarchar(20),@iterations) + ' iterations.'
		raiserror (@msg, 0, 1) with nowait

	END

	if object_id('tempdb..#todelete') is not null
		begin
		set @msg = '(' + format(getdate(),'s') + '): remove existing temp table'
			raiserror (@msg, 0, 1) with nowait
		DROP TABLE #todelete
		end

	set @msg = '(' + format(getdate(),'s') + '): Deleted ' + convert(nvarchar(20),@deletedtotal) + ' lines in ' + convert(nvarchar(20),datediff(second,@startdate,Getdate())) + ' seconds in ' + convert(nvarchar(20),@iterations) + ' iterations.'
	raiserror (@msg, 0, 1) with nowait

-- have a nice index afterwards | ReBuilts indexes on the tblsoftware
	set @msg = '(' + format(getdate(),'s') + '): renewing indexes.'
	raiserror (@msg, 0, 1) with nowait

	Alter index all on tblsoftware rebuild with (online = on)

	set @msg = '(' + format(getdate(),'s') + '): done in ' + convert(nvarchar(20),datediff(second,@startdate,Getdate())) + ' seconds.'
	raiserror (@msg, 0, 1) with nowait
END
GO