/******
Script that helps establish if there are OS data from INV to SLm that are out of sync
This will help you understand what rough sequence number you will need to revert to 
in the DUJ to hopefully ensure that this OS attribute flow from INV to SLM
Created: 2020/12/11
Written by: Kris Wong
Modified by: Kris Wong 2021/01/09
******/
USE SnowLicenseManager
SELECT	c.CID
		,c.hostname
		,invos.name as 'Raw_OS_From_INV'
		,c.OperatingSystem as 'SLM_OS_Raw'
		,nos.name as 'SLM_OS_Normalized'
		,cv.SequenceNumber as 'ComputerSequence'		
		,c.LastScanDate
FROM tblcomputer c
	INNER JOIN inv.tblComputerInvSlmMap map on
		c.ComputerID=map.ComputerID
	INNER JOIN SnowInventory.inv.DataClientView2 cv on
		cv.clientid=map.ClientId
	INNER JOIN SnowInventory.inv.[DataOperatingSystem] invos on
		map.ClientId=invos.ClientId
	LEFT JOIN  (
		SELECT	a.name
				,ca.computerid
				,a.IsOS
			FROM [SnowLicenseManager].[dbo].[tblComputerApplications] ca
				join tblapplication a on
					a.applicationid=ca.applicationid
			WHERE a.isos=1) nos on nos.ComputerID=c.ComputerID
	LEFT JOIN SnowLicenseManager.DBO.tblComputerOperatingSystem slmos on
		map.ComputerID=slmos.ComputerId
WHERE c.OperatingSystem != invos.name
ORDER by 6
