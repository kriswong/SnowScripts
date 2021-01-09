/***************************************
Inserting into SLM..tblSystemCustomProcedures

This script will insert a new row on the tblSystemCustomProcedures table
It gathers the highest number in ExecutionOrder field, adds 1 to it, and
uses that number for the insertion.

Note that the default are defined, and will need to be customized on lines 33-37

Written by: Landon Owens
Modified by Kris Wong for Daildrop tblsoftware
Date: 2020-11-10
****************************************/

/**********
Modified this script to allow for a PRE and/or POST addition of the "_Clean_tblsoftware"
Script that Oliver Berger originally created but I modified.  The idea is that by adding
a Customer Procedure to Pre and Post DUJ this should allow an SPE system to stay fairly
Clean of these orphaned entried on the tblsoftware.

Modified by: Kris Wong
Date: 2020-12-22
**********/

GO
-- Declaring Variables
Declare @SP_DatabaseName nvarchar(100)	-- Database where the SP/Script is located
Declare @SP_ProcedureOwner nvarchar(50)	-- Schema/User that will execute the SP/Script
Declare @SP_ProcedureName nvarchar(255)	-- Name of the SP/Script
Declare @SP_Arguments nvarchar(1024)	-- Any arguments that are needed to be passed to the SP/Script
Declare @SP_ExecOrder int				-- The order of execution It needs to be unique in the Pre or Post job order
Declare @SP_PostJobbit bit				-- Bit for 0 = Before DUJ, 1 = After DUJ

-- Preping variables with default values
Set @SP_DatabaseName = 'SnowLicenseManager'
Set @SP_ProcedureOwner = 'dbo'
Set @SP_ProcedureName = 'You_did_it_Wrong'
Set @SP_Arguments = NULL
Set @SP_ExecOrder = 0
Set @SP_PostJobbit  = 0
-- ********* Set values for your insertion here! *********
Set @SP_DatabaseName = 'SnowLicenseManager'
Set @SP_ProcedureOwner = 'dbo'
Set @SP_ProcedureName = '_Clean_TblSoftware'
Set @SP_Arguments = '@softwareRange=100000,@deleteBatchsize=10000,@maxRunTimeMins=60'
Set @SP_PostJobbit = 0

-- Finding the execution order alligned with the PostJobBit.
Select @SP_ExecOrder=coalesce(max(ExecutionOrder), 0) + 1 from SnowLicenseManager.dbo.tblSystemCustomProcedures where PostJob = @SP_PostJobbit 

-- Inserting into tblSystemCustomProcedures
insert into SnowLicenseManager.dbo.tblSystemCustomProcedures (DatabaseName, ProcedureOwner, ProcedureName, ProcedureArguments, ExecutionOrder, PostJob) 
values (@SP_DatabaseName, @SP_ProcedureOwner, @SP_ProcedureName, @SP_Arguments, @SP_ExecOrder, @SP_PostJobbit) 

-- Checking your work
Select * from SnowLicenseManager.dbo.tblSystemCustomProcedures

--Deleting the misstake
--Delete from SnowLicenseManager.dbo.tblSystemCustomProcedures
--where ProcedureName = '_Clean_TblSoftware'
