/**********
****Use this at your own risk.****
Script that will attempt to remove the Orphaned Objects within SLM based on ComputerID
It is a "known" issue in the community that when you Delete CID that Orphaned Objects
Are left within SLM in various table and for various reasons. This Script is an attempt
To remove these Orphaned Objects and make the Database more prestine than it current is.
****Use this at your own risk.****
Created By: Kris Wong
Created Date: 2020/09/31
Modified on: 2021/01/08 
***Disclaimer***
Do not use this on production without adequate testing.  There maybe mistakes, errors, or 
omissions within the script that can cause ***irreversal*** damage to your SLM database.
****Use this at your own risk.****
Tables that are NOT cleaned by the Delete Command
[SnowLicenseManager].[archive].[tblContractComputers]
[SnowLicenseManager].[dbo].[RsComputerSearchOs]
[SnowLicenseManager].[dbo].[RsExclusions]
[SnowLicenseManager].[dbo].[RsWebSnowboardOSPlatform]
[SnowLicenseManager].[dbo].[rsApiComputersHardware]
[SnowLicenseManager].[dbo].[tblAddonComputerIbmPVU]
[SnowLicenseManager].[dbo].[tblAddonSoftwareFullversion] ***
[SnowLicenseManager].[dbo].[tblComputerArchiveCustomFields]
[SnowLicenseManager].[dbo].[tblComputerArchive]
[SnowLicenseManager].[dbo].[tblComputerOperatingSystemSoftwareChecksum] ***
[SnowLicenseManager].[dbo].[tblCostsPerComputerAndApplication]
[SnowLicenseManager].[dbo].[tblInventoryVirtualMachines]
[SnowLicenseManager].[omo].[DatabaseFeatureUsageStats]
[SnowLicenseManager].[omo].[DatabaseInstances]
[SnowLicenseManager].[omo].[DatabaseServers]
[SnowLicenseManager].[omo].[DatabaseSessions]
[SnowLicenseManager].[omo].[LicenseRequirement]
[SnowLicenseManager].[omo].[MiddlewareDomain]
[SnowLicenseManager].[omo].[MiddlewareInstallation]
[SnowLicenseManager].[omo].[MiddlewareServer]
[SnowLicenseManager].[omo].[ScanMiddlewareDistribution]
[SnowLicenseManager].[omo].[ScanMiddlewareDomain]
[SnowLicenseManager].[omo].[ScanMiddlewareServer]
[SnowLicenseManager].[vir].[ComputerCluster]
[SnowLicenseManager].[vir].[ComputerDatacenter]
[SnowLicenseManager].[vir].[LparConfiguration]
[SnowLicenseManager].[vir].[ScanLparData]
[SnowLicenseManager].[vir].[VmWareConfiguration]
If these contain Orphaned Data, then you could use a manual deletion process on similar
to the following:
--Delete from [SnowLicenseManager].[dbo].[Table containing orphaned data]
--	where ComputerId not in (Select b.computerid from tblcomputer b)
***This Assumes that the TBLComputer is accurate and complete.
**********/

USE [SnowLicenseManager]
GO
DROP TABLE IF EXISTS  #Orphaned
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

With C1 as (
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerApplicationPVU]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerApplicationUsers]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerApplicationsHistory]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerApplications]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerBundleSuppression]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerClient]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerCoreFactor]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerDisplayAdapter]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerEnvironment]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerHardware]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerHostHistory]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerIBMPVU]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerInBox]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerInfo]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerLicenseTransfer]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerLogicalDisk]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerMemoryModule]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerMemory]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerMonitor]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerNetworkAdapter]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerOperatingSystem]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerPhysicalDisk]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerPrinter]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerProcessor]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerRegistry]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerSoftwareInstalled]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerSoftwareProduct]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerSoftwareWork]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerSoftware]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerUsers]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerVirtualPackage]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerWinServerInventoryRisks]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerWinServerInventory]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblComputerWith64BitSoftware]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblContractComputers]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblDCCFeatures]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblDCCMembers]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblDataCenterClient]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblDataCenterFeature]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblDataCenterVirtualMachine]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblExcludedComputer]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblLoginUserClient]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblMeteringCloud]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblMetering]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblMobileDeviceProperty]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblObject]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblOracleComputerOrderItems]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblOracleDatabaseFeatureUsageStats]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblOracleDatabaseInstances]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblOracleDatabaseServers]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblOracleDatabaseSessions]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblQuarantineComputer]with (NOLOCK)
	Union
SELECT Distinct ComputerID FROM [SnowLicenseManager].[dbo].[tblWebAppMetering]with (NOLOCK)
)

select C1.ComputerID into #Orphaned
	from C1
		left join [SnowLicenseManager].[dbo].[tblComputer] C on
		C1.ComputerID=C.ComputerID
	WHERE C.ComputerID is null and C1.computerID>0
;
Begin
print 'Will delete all Orphaned Objects from SnowLicenseManager'

declare @Compid int
declare compkiller cursor for select ComputerID from #Orphaned
open compkiller
fetch next from compkiller into @Compid
	While (@@FETCH_STATUS=0)
		Begin
			exec computerdelete 0, @Compid, 'OrphanedComputerScript', 0
		fetch next from compkiller into @compid
		end
		close compkiller
	deallocate compkiller
	print 'Orphaned Objects from SnowLicenseManager have been Deleted'
end