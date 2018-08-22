<!---

APPS INVENTORY SERVICE

THESE SERVICES ARE PROVIDED TO REPLACE THE FORMER LOOK-UP INTO APPS INVENTORY FOR 
APPLICATION LISTS AND APPLICATION MANAGERS.

WHILE IT PRIOR USED TO DO A LOOKUP INTO THE Applications Inventory DATABASE FOR THIS INFORMATION,
IT IS NOW (TECHNICALLY) SUPPOSED TO LOOK INTO SERVICE DESK, THE SYSTEM OF RECORD.

SO WE USE A WEB SERVICE TO DO THE LOOKUP AND IT SEEMS TO BE WORKING PRETTY WELL.

--->


<cfcomponent>


<!---- 
IMPLEMENTATION OF: GetApplicationList

USAGE:
  
<cfinvoke component="cfc.services.AppsInventory.service"  method="GetApplicationList" returnvariable="rv">

---->
	<cffunction name="GetApplicationList" access="public" hint="Return a list of Applications">
		
		
		<cfif IsDefined("SESSION.Cached_GetApplicationList")>
		
			<Cfset wsreturndata = SESSION.Cached_GetApplicationList>
		
		<cfelse>
		
			<!--- pull application list from web service --->
		
			<cfinvoke webservice="http://orlandohealthsoa.orhs.org/applicationinventory/applicationinventoryservice.svc?wsdl"
					  method="ApplicationsSearchList"
					  returnvariable="wsreturndata"  refreshwsdl="yes">

			<Cfset ApplicationListFromSD = QueryNew("System,ManagerName,ManagerUseID,ManagerEmail,ApplicationId")>

			<Cfloop array="#wsreturndata.Application#" index="App">
			<Cfif App.Active EQ "YES"> 
			    <cfset temp = QueryAddRow(ApplicationListFromSD)> 
			    <cfset Temp = QuerySetCell(ApplicationListFromSD, "System", Trim(App.Name))> 
			    <cfset Temp = QuerySetCell(ApplicationListFromSD, "ManagerName", Trim(App.ISOwnerGroupManagerName))> 
			    <cfset Temp = QuerySetCell(ApplicationListFromSD, "ManagerUseID", Trim(App.ISOwnerGroupManagerUserId))> 
			    <cfset Temp = QuerySetCell(ApplicationListFromSD, "ManagerEmail", Trim(App.ISOwnerGroupManagerEmail))> 
			    <cfset Temp = QuerySetCell(ApplicationListFromSD, "ApplicationId", Trim(App.ApplicationId))> 
			    
			</CFIF>		
			</cfloop>

			<!--- pull function list from web service --->
				
 			<cfinvoke webservice="http://orlandohealthsoa.orhs.org/applicationinventory/applicationinventoryservice.svc?wsdl"
 					  method="GetFunctionNonApplication"
					  returnvariable="wsfunctions"  refreshwsdl="yes">
			
			<Cfset FunctionListFromSD = QueryNew("Function")>

			<Cfloop array="#wsfunctions.FunctionNonApplication#" index="Fun">
	
			<Cfif Fun.Active EQ "YES"> 
			
				<cfquery dbtype="query" name="FunctionInApplicationList">
					SELECT System as cnt FROM ApplicationListFromSD
					WHERE ApplicationListFromSD.System = '#fun.Name#'
				</cfquery>

				<cfif FunctionInApplicationList.RecordCount eq 0>
				    <cfset temp = QueryAddRow(FunctionListFromSD)> 
				    <cfset Temp = QuerySetCell(FunctionListFromSD, "Function", Trim(Fun.Name))> 

				</cfif>
				
			
		    
			</CFIF>		
			</cfloop>					

			<!--- combine applications and functions into single ColdFusion query --->

 			<cfquery name="wsreturndata" dbtype="query">
				SELECT System
				      ,[ManagerName]
				      ,[ManagerUseID]
				      ,[ManagerEmail]
				      ,lower(System) as SortSystem
				FROM ApplicationListFromSD
				union
				SELECT Function, '', '', '', lower(Function)
				FROM FunctionListFromSD
				order by [SortSystem]
			</cfquery>


				
			<cfset SESSION.Cached_GetApplicationList = wsreturndata>
			
		</cfif>
	
		<Cfreturn wsreturndata>
	</cffunction>

<!---- 
IMPLEMENTATION OF: GetApplicationByName

USAGE:
  
<cfinvoke component="cfc.services.AppsInventory.service"  method="GetApplicationByName" returnvariable="rv" Name="Accounting of Disclosures">


---->

	<cffunction name="GetApplicationByName" access="public" hint="Return an Applications by its name">
		<cfargument name="Name" type="string" required="Yes">
		

		<cfinvoke webservice="http://orlandohealthsoa.orhs.org/applicationinventory/applicationinventoryservice.svc?wsdl"
				  method="GetApplicationByName"
				  returnvariable="wsreturndata"  refreshwsdl="yes" Name="#Name#" Active="true">
	
	
		<cfset nQuery = QueryNew("AcquireDate,Active,AdditionalNotes,ApplicationId,ApplicationType,BusinessAssociateAgreementDate,CategoryType,DeliveryMechanism,Description,DisasterTier,FunctionalSupportContactName,FunctionalSupportGroup,FunctionalSupportGroupId,HasPHI,ICDCode,InstallationDate,LastModDate,LicenseType,MaintenanceExpirationDate,MaintenanceFee,MaintenancePeriod,Manager,ManufactureVendorName,Name,Nickname,PurchasingVendorName,ServiceStatus,SupportGroup,SupportLevel,SupportType,SupportVendorName,TechnicalSupportContactName,TechnicalSupportManagerName,Version",
					 "Date,VarChar,VarChar,VarChar,VarChar,Date,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar")>
		<cfset temp = QueryAddRow(nQuery)>
		<cfset Temp = QuerySetCell(nQuery, "AcquireDate", wsreturndata.AcquireDate)>
		<cfset Temp = QuerySetCell(nQuery, "Active", wsreturndata.Active)>
		<cfset Temp = QuerySetCell(nQuery, "AdditionalNotes", wsreturndata.AdditionalNotes)>
		<cfset Temp = QuerySetCell(nQuery, "ApplicationId", wsreturndata.ApplicationId)>
		<cfset Temp = QuerySetCell(nQuery, "ApplicationType", wsreturndata.ApplicationType)>
		<cfset Temp = QuerySetCell(nQuery, "BusinessAssociateAgreementDate", wsreturndata.BusinessAssociateAgreementDate)>
		<cfset Temp = QuerySetCell(nQuery, "CategoryType", wsreturndata.CategoryType)>
		<cfset Temp = QuerySetCell(nQuery, "DeliveryMechanism", wsreturndata.DeliveryMechanism)>
		<cfset Temp = QuerySetCell(nQuery, "Description", wsreturndata.Description)>
		<cfset Temp = QuerySetCell(nQuery, "DisasterTier", wsreturndata.DisasterTier)>
		<cfset Temp = QuerySetCell(nQuery, "FunctionalSupportContactName", wsreturndata.FunctionalSupportContactName)>
		<cfset Temp = QuerySetCell(nQuery, "FunctionalSupportGroup", wsreturndata.FunctionalSupportGroup)>
		<cfset Temp = QuerySetCell(nQuery, "FunctionalSupportGroupId", wsreturndata.FunctionalSupportGroupId)>
		<cfset Temp = QuerySetCell(nQuery, "HasPHI", wsreturndata.HasPHI)>
		<cfset Temp = QuerySetCell(nQuery, "ICDCode", wsreturndata.ICDCode)>
		<cfset Temp = QuerySetCell(nQuery, "InstallationDate", wsreturndata.InstallationDate)>
		<cfset Temp = QuerySetCell(nQuery, "LastModDate", wsreturndata.LastModDate)>
		<cfset Temp = QuerySetCell(nQuery, "LicenseType", wsreturndata.LicenseType)>
		<cfset Temp = QuerySetCell(nQuery, "MaintenanceExpirationDate", wsreturndata.MaintenanceExpirationDate)>
		<cfset Temp = QuerySetCell(nQuery, "MaintenanceFee", wsreturndata.MaintenanceFee)>
		<cfset Temp = QuerySetCell(nQuery, "MaintenancePeriod", wsreturndata.MaintenancePeriod)>
		<cfset Temp = QuerySetCell(nQuery, "Manager", wsreturndata.Manager)>
		<cfset Temp = QuerySetCell(nQuery, "ManufactureVendorName", wsreturndata.ManufactureVendorName)>
		<cfset Temp = QuerySetCell(nQuery, "Name", wsreturndata.Name)>
		<cfset Temp = QuerySetCell(nQuery, "Nickname", wsreturndata.Nickname)>
		<cfset Temp = QuerySetCell(nQuery, "PurchasingVendorName", wsreturndata.PurchasingVendorName)>
		<cfset Temp = QuerySetCell(nQuery, "ServiceStatus", wsreturndata.ServiceStatus)>
		<cfset Temp = QuerySetCell(nQuery, "SupportGroup", wsreturndata.SupportGroup)>
		<cfset Temp = QuerySetCell(nQuery, "SupportLevel", wsreturndata.SupportLevel)>
		<cfset Temp = QuerySetCell(nQuery, "SupportType", wsreturndata.SupportType)>
		<cfset Temp = QuerySetCell(nQuery, "SupportVendorName", wsreturndata.SupportVendorName)>
		<cfset Temp = QuerySetCell(nQuery, "TechnicalSupportContactName", wsreturndata.TechnicalSupportContactName)>
		<cfset Temp = QuerySetCell(nQuery, "TechnicalSupportManagerName", wsreturndata.TechnicalSupportManagerName)>
		<cfset Temp = QuerySetCell(nQuery, "Version", wsreturndata.Version)>

	
		<Cfreturn nQuery>
	</cffunction>

<!---- 
IMPLEMENTATION OF: GetOneApplication

USAGE:
  
<cfinvoke component="cfc.services.AppsInventory.service"  method="GetOneApplication" ParmApplicationName="Change Control" returnvariable="rv">

---->
	<cffunction name="GetOneApplication" access="public" hint="Return one Application Record">
		<cfargument name="ParmApplicationName" type="string" required="Yes" default="">
		
		<cfinvoke component="cfc.services.AppsInventory.service"  method="GetApplicationList" returnvariable="rvL">
 	
	
		<cfquery dbtype="query" name="wsreturndata">
			SELECT  *
			FROM rvL
			WHERE UPPER([System]) = UPPER('#ParmApplicationName#')
		</cfquery>

		<Cfreturn wsreturndata>
	</cffunction>

	
</cfcomponent>