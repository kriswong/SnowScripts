/*  The purpose of this code is to trigger the OS record to be pushed from SI to SLM.
	This should run as a PostJob custom stored procedure in tblSystemCustomProcedures.  
	It removes the operating system row from the ChangeHashTree table which will trigger
	the OS record to be moved to SLM the next time an inventory file is processed. 	
	
	This is not a proactive step.  In will only trigger new data to come over before the
	next DUJ runs, not the current one. This problem is caused by a timing issue with the
	steps in the DUJ when a computer first shows up.  It's a known issue which will be 
	addressed in a later release of SLM. */


	Delete from snowinventory.inv.ChangeHashTree
	where path = '/operatingsystem'
	and Clientid in 
	(Select MAP.Clientid
	from snowlicensemanager.dbo.tblcomputer c
	Inner join snowlicensemanager.inv.tblComputerInvSlmMap map on c.Computerid = map.ComputerID
	Inner join SnowInventory.slm.ClientSiteDBMap cmap on map.clientid = cmap.clientid and map.InventoryDBID = cmap.InventoryDBID
	Inner join snowinventory.inv.DataOperatingSystemView2 os on map.ClientId = os.ClientId
	Where (c.OperatingSystem = '' or c.Operatingsystem IS NULL)
	AND os.Name is not null)
	

/*  The SQL below can be run to see what operating systems are missing in SLM which will be populated the next time an inventory file is processed
	select map.*, c.hostname, operatingsystem , os.*
	from snowlicensemanager.dbo.tblcomputer c
	Inner join snowlicensemanager.inv.tblComputerInvSlmMap map on c.Computerid = map.ComputerID
	Inner join SnowInventory.slm.ClientSiteDBMap cmap on map.clientid = cmap.clientid and map.InventoryDBID = cmap.InventoryDBID
	inner join snowinventory.inv.DataOperatingSystemView2 os on map.ClientId = os.ClientId
	Where (c.OperatingSystem = '' or c.Operatingsystem IS NULL)
	AND os.Name is not null


*/	