<!-----------------------------------------------------------------------********************************************************************************Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corpwww.coldboxframework.com | www.luismajano.com | www.ortussolutions.com********************************************************************************Author: Oscar Arevalo (oarevalo@gmail.com) & Luis MajanoDate:   October/2005Description:This tool is used to display information about all components located withinthe same directory. The tools is based on the coldfusion.runtime.TemplateProxyjava object to obtain this information or if using a CFML engine that supportsgetComponentMetadata(). ----------------------------------------------><cfcomponent name="CFCViewer"			 hint="This components provides functionality to obtain information about cfcs via introspection."			 extends="coldbox.system.Plugin"			 output="false"			 cache="false"><!------------------------------------------- CONSTRUCTOR ------------------------------------------->	<cffunction name="init" access="public" returntype="CFCViewer" output="false">		<cfargument name="controller" type="any" required="true">		<cfscript>			super.Init(arguments.controller);						/* Plugin Details */			setpluginName("CFC Viewer");			setpluginVersion("2.0");			setpluginDescription("CFC metadata introspection plugin");			setpluginAuthor("Luis Majano");			setpluginAuthorURL("http://www.coldbox.org");						/* Plugin properties */			setDirPath("");			setRootPath("");						/* CfC's & Packages */			setaCFC( ArrayNew(1) );			setaPacks( ArrayNew(1) );						/* Styles */			setStyleSheet( "" );			setlstAccessTypes( "public,private,remote,package" );			setRenderingTemplate("/coldbox/system/includes/cfcviewer/CFCViewer.cfm");			setLinkBaseURL("");						return this;		</cfscript>			</cffunction><!------------------------------------------- PUBLIC ------------------------------------------->	<!--- Setup the component --->	<cffunction name="setup" access="public" output="false" returntype="CFCViewer" hint="Use this method to initialize for documentation. You must persist it in your request so you can do renderings and interact with the object.">		<!--- ************************************************************* --->		<cfargument name="dirpath" 				type="string" required="yes" 	hint="The directory path to which is the root of what you want the cfcviewer to report on. This must be a valid instantiation path: ex: /coldbox/system">		<cfargument name="accessTypesFilter" 	type="string" required="no" 	default=""	hint="Use this argument to only display methods with the access types given. If empty, displays all methods (public, private, remote, package).">		<cfargument name="dirLink"  			type="string" required="false"  hint="If you pass this. it will create a linkable directory or package structure according to the link provided and append an internal package variable.">		<cfargument name="jsLink"   			type="string" required="false" 	hint="If you pass this, it will create a linkable package according to the js provided. Also, place a @package@ on your link, so it can correctly identify where to place the url parameter for the package choosen">		<cfargument name="RenderingTemplate" 	type="string" required="false" 	hint="Override the rendering template with yours"/>		<cfargument name="LinkBaseURL" 			type="string" required="false" hint="The base url to use for anchors"/>		<!--- ************************************************************* --->		<cfset var qryCFC = "">		<cfset var i = 0>		<cfset var event = controller.getRequestService().getContext()>		<cfset var expandedPath = "">		<cfset var incomingPath = "">				<!--- Clean Path --->		<cfif right(arguments.dirPath,1) neq "/">			<cfset arguments.dirPath = arguments.dirPath & "/">		</cfif>		<!--- Set Paths --->		<cfset setDirPath(arguments.dirpath)>		<cfset expandedPath = getAbsolutePath(arguments.dirpath)>		<!--- Save Root --->		<cfset setRootPath(getDirPath())>					<!--- Do we Have a package Name --->		<cfif event.valueExists('_cfcviewer_package')>			<!--- Clean the incoming value --->			<cfset incomingPath = reReplacenocase(urlDecode(event.getValue("_cfcviewer_package")),"\s\(\d*\)$","")>			<!--- set new expanded path now --->			<cfset expandedPath = expandedPath & incomingPath>			<!--- Set new dir path --->			<cfset setDirPath(getDirPath() & incomingPath )>		</cfif>				<!--- get the list of cfc and package files on the directory path choosen or incoming --->		<cfdirectory action="list" directory="#expandedPath#" name="qryCFC" sort="name">				<cfscript>			/* Init our viewer */			setaCFC(arrayNew(1));			setaPacks(arrayNew(1));						/* Access Types */			if( arguments.accessTypesFilter.length() neq 0){				setlstAccessTypes( arguments.accessTypesFilter );			}						//Get components for root package			for(i=1;i lte qryCFC.RecordCount;i=i+1) {				if(Right(qryCFC.Name[i],4) eq ".cfc") {					ArrayAppend(getaCFC(), ListGetAt(qryCFC.Name[i],1,"."));				}			}			ArraySort(getaCFC(),"textnocase","asc");									/* Build Packages for Root Path */			instance.aPacks = buildPackages(aPackages=getaPacks(),directory=getAbsolutePath(getRootPath()),parentName="");			ArraySort(instance.aPacks,"textnocase","asc");						/* Link Type & Strings */			if( structKeyExists(arguments,"dirLink") ){				setLinkType("normal");				setLinkString(arguments.dirLink);			}			else{				setLinkType("js");				setLinkString(arguments.jsLink);			}						/* Rendering Template Override */			if( structKeyExists(arguments,"RenderingTemplate") and arguments.RenderingTemplate.length() ){				setRenderingTemplate(arguments.RenderingTemplate);			}			/* Base URL */			if( structKeyExists(arguments,"LinkBaseURL") and arguments.LinkBaseURL.length() ){				setLinkBaseURL(arguments.LinkBaseURL);			}									//Return instance			return this;		</cfscript>	</cffunction>		<!--- Get CFCMetadata --->	<cffunction name="getCFCMetaData" access="public" returntype="any" output="false" hint="returns a structure with information about the given component. This structure contains information about returntype, methods, parameters, etc.">		<!--- ************************************************************* --->		<cfargument name="cfcName" type="string" required="yes" hint="The name of the cfc">		<!--- ************************************************************* --->		<cfset var proxy = "">		<cfset var cfcPathDot = ListChangeDelims(getDirPath(),".","/")>		<cfset var cfcLocation = "">		<cfset var md = structNew()>		<cftry>			<!--- cfcLocation --->			<cfif left(cfcPathDot,1) eq "/">				<cfset cfcPathDot = right(cfcPathDot, len(cfcPathDot)-1)>			</cfif>						<!--- CfcLocation --->			<cfset cfcLocation = cfcPathDot & "." & Arguments.cfcName>						<!--- Metadata --->			<cfif controller.oCFMLENGINE.isComponentData()>				<cfset md = getComponentMetaData(cfcLocation)>			<cfelse>				<cfset proxy = CreateObject("java", "coldfusion.runtime.TemplateProxy")>				<cfset md = proxy.getMetaData(cfcLocation, getPageContext())>			</cfif>						<!--- Default Inheritance Tree --->			<cfset md.inheritanceTree = ArrayNew(1)>						<!--- Build Tree if it exists --->			<cfif structKeyExists(md,"extends") and not isSimpleValue(md.extends) and 			      structKeyExists(md.extends,"name") and md.extends.name neq "WEB-INF.cftags.component" >				<cfset md.inheritanceTree = inheritanceRecursion(md.inheritanceTree,md.extends)>				</cfif>						<cfcatch  type="any">				<cfthrow type="CFCViewer.GettingMetaDataException" message="#cfcatch.Message#" detail="#cfcatch.Detail# - args: #arguments.cfcname# #cfcatch.stackTrace#">			</cfcatch>		</cftry>				<cfreturn md>	</cffunction>		<!--- Render stuff --->	<cffunction name="renderit" access="public" returntype="any" output="false" hint="Render the content">		<cfset var ccv = "">		<cfset var RenderingTemplate = getRenderingTemplate()>		<cfsavecontent variable="ccv"><cfinclude template="#RenderingTemplate#"></cfsavecontent>		<cfreturn ccv>	</cffunction>		<!--- Build a package Link --->	<cffunction name="buildLink" access="public" returntype="string" hint="Build a link for a package name" output="false" >		<cfargument name="package" required="true" type="string" hint="">
		<cfscript>			var thisURL = "";			var linkPackage = "";			var urlString = "";						/* Clean Package Name */			arguments.package = replacenocase(arguments.package,".","/","all");			arguments.package = reReplacenocase(arguments.package,"\s\(\d*\)$","");			arguments.package = urlencodedformat(arguments.package);						/* Clean URL String */			urlString = "_cfcviewer_package=" & arguments.package;						/* js or normal */			if( getLinkType() eq "js" ){				/* Replace package name */				urlString = replacenocase(getLinkString(),"@package@",urlString);				thisURL = "javascript:#urlString#";			}			else{				urlString = getLinkString() & "&" & urlString;				thisURL = urlString;			}						/* Return url */			return thisURL;		</cfscript>	</cffunction>		<!--- Build Root Link --->	<cffunction name="buildRootLink" access="public" returntype="string" hint="Build a link for a root name" output="false" >		<cfscript>			var thisURL = "";			var urlString = replacenocase(getLinkString(),"@package@","","all");						/* js or normal */			if( getLinkType() eq "js" ){				thisURL = "javascript:#urlString#";			}			else{				thisURL = urlString;			}						/* Return url */			return thisURL;		</cfscript>	</cffunction>	<!------------------------------------------- INTANCE ACCESSORS/MUTATORS ------------------------------------------->	<!--- Get/Set StyleSheet --->	<cffunction name="getStyleSheet" access="public" returntype="string" output="false"	hint="Get the stylesheet to use when rendering the documentation.">		<cfreturn instance.styleSheet>	</cffunction>	<cffunction name="setStyleSheet" access="public" returntype="void" output="false" hint="Set the stylesheet to use when rendering the documentation">		<cfargument name="styleSheet" type="string" required="true">		<cfset instance.styleSheet = arguments.styleSheet>	</cffunction>	<!--- Dir Path --->	<cffunction name="getDirpath" access="public" returntype="string" output="false" hint="Get the dirpath of where the cfc's reside. This is expanded.">		<cfreturn instance.dirpath>	</cffunction>	<cffunction name="setdirpath" access="public" returntype="void" output="false" hint="Set the dirpath">		<cfargument name="dirpath" type="string" required="true">		<cfset instance.dirpath = arguments.dirpath>	</cffunction>	<!--- List Access Types --->	<cffunction name="getlstAccessTypes" access="public" returntype="string" output="false" hint="Get lstAccessTypes">		<cfreturn instance.lstAccessTypes>	</cffunction>	<cffunction name="setlstAccessTypes" access="public" returntype="void" output="false" hint="Set lstAccessTypes">		<cfargument name="lstAccessTypes" type="string" required="true">		<cfset instance.lstAccessTypes = arguments.lstAccessTypes>	</cffunction>		<!--- Get set cfc's' --->	<cffunction name="getaCFC" access="public" returntype="array" output="false" hint="returns an array with the names of all components within the current directory">		<cfreturn instance.aCFC>	</cffunction>	<cffunction name="setaCFC" access="public" output="false" returntype="void" hint="Set CFCs">
		<cfargument name="aCFC" type="array" required="true"/>
		<cfset instance.aCFC = arguments.aCFC/>
	</cffunction>		<!--- get set pkgs --->	<cffunction name="getaPacks" access="public" output="false" returntype="array" hint="Get aPacks">
		<cfreturn instance.aPacks/>
	</cffunction>
	<cffunction name="setaPacks" access="public" output="false" returntype="void" hint="Set aPacks">
		<cfargument name="aPacks" type="array" required="true"/>
		<cfset instance.aPacks = arguments.aPacks/>
	</cffunction>		<!--- Set the link type to use --->	<cffunction name="getlinkType" access="public" output="false" returntype="string" hint="Get linkType">
		<cfreturn instance.linkType/>
	</cffunction>
	<cffunction name="setlinkType" access="public" output="false" returntype="void" hint="Set linkType">
		<cfargument name="linkType" type="string" required="true"/>
		<cfset instance.linkType = arguments.linkType/>
	</cffunction>		<!--- Get set link string --->	<cffunction name="getlinkString" access="public" output="false" returntype="string" hint="Get linkString">
		<cfreturn instance.linkString/>
	</cffunction>
	<cffunction name="setlinkString" access="public" output="false" returntype="void" hint="Set linkString">
		<cfargument name="linkString" type="string" required="true"/>		<cfif right(arguments.linkString,1) eq "&">
			<cfset instance.linkString = left(arguments.linkstring, len(arguments.linkstring)-1) />		<cfelse>			<cfset instance.linkString = arguments.linkString/>		</cfif>
	</cffunction>		<!--- Get Root Path --->	<cffunction name="getrootPath" access="public" output="false" returntype="string" hint="Get rootPath">
		<cfreturn instance.rootPath/>
	</cffunction>
	<cffunction name="setrootPath" access="public" output="false" returntype="void" hint="Set rootPath">
		<cfargument name="rootPath" type="string" required="true"/>
		<cfset instance.rootPath = arguments.rootPath/>
	</cffunction>	<!--- Rendering Template --->	<cffunction name="getRenderingTemplate" access="public" returntype="string" output="false" hint="Get rendering template to use">
		<cfreturn instance.RenderingTemplate>
	</cffunction>
	<cffunction name="setRenderingTemplate" access="public" returntype="void" output="false" hint="Set the rendering template to use">
		<cfargument name="RenderingTemplate" type="string" required="true">
		<cfset instance.RenderingTemplate = arguments.RenderingTemplate>
	</cffunction>		<!--- Get/set base URL --->	<cffunction name="getLinkBaseURL" access="public" returntype="string" output="false">
		<cfreturn instance.LinkBaseURL>
	</cffunction>
	<cffunction name="setLinkBaseURL" access="public" returntype="void" output="false">
		<cfargument name="LinkBaseURL" type="string" required="true">
		<cfset instance.LinkBaseURL = arguments.LinkBaseURL>
	</cffunction>	<!------------------------------------------- PRIVATE ------------------------------------------->	<!--- Get Aboslute Path --->	<cffunction name="getAbsolutePath" access="private" returntype="string" hint="Get an absolute path" output="false" >		<cfargument name="targetPath" required="true" type="string" hint="">		<cfscript>			var expandedPath = expandPath(arguments.targetPath);			var goodPath = "";						/* Determine Paths */			if( directoryExists(expandedPath) ){				goodPath = expandedPath;				/* Append Last / */				if( right(goodPath,1) neq "/")					return goodPath & "/";				else					return goodPath;			}			else{				$throw("Directory Does not exist","Directory = #arguments.targetPath#","plugins.CFCViewer.DirectoryNotFound");			}								</cfscript>	</cffunction>		<!--- Build Package Array --->	<cffunction name="buildPackages" access="private" returntype="array" hint="Create an array of package names" output="false" >		<!--- ************************************************************* --->		<cfargument name="aPackages"  required="true" type="Array"  hint="The array to append to">		<cfargument name="directory"  required="true" type="string" hint="The target directory to recurse">		<cfargument name="parentName" required="true" type="string" hint="The parent package">		<!--- ************************************************************* --->		<cfset var qPackages = "">		<cfset var thisPackageName = "">		<cfset var slash = getSetting("OSFileSeparator",1)>		<cfset var qComponents = "">				<!--- list the directory --->		<cfdirectory action="list" name="qPackages" 	directory="#arguments.directory#" sort="asc">		<cfdirectory action="list" name="qComponents" 	directory="#arguments.directory#" filter="*.cfc">				<!--- If no cfc's and no packages, exit --->		<cfif qComponents.recordcount eq 0 and qPackages.recordCount eq 0>			<cfreturn arguments.aPackages>		</cfif>				<!--- Loop over directories --->		<cfloop query="qPackages">			<cfif qPackages.type eq "Dir" and qPackages.name neq ".svn">							<!--- Calculate package Name --->				<cfif arguments.parentName.length() eq 0>					<cfset thisPackageName = Name>				<cfelse>					<cfset thisPackageName = arguments.parentName & "." & Name>				</cfif>								<!--- Append to array, if any component exists --->				<cfdirectory action="list" name="qComponents" 	directory="#arguments.directory##slash##name#" filter="*.cfc">				<cfif qComponents.recordcount neq 0>					<cfset arrayAppend(arguments.aPackages,thisPackageName & " (#qComponents.recordcount#)")>				</cfif>								<!--- Recurse --->				<cfset arguments.aPackages = buildPackages(arguments.aPackages,directory & slash & name,thisPackageName)>			</cfif>		</cfloop>				<!--- Return Array --->		<cfreturn arguments.aPackages>	</cffunction>		<!--- Inheritance recursion --->	<cffunction name="inheritanceRecursion" access="private" returntype="array" hint="Inheritance Recursion" output="false" >		<!--- ************************************************************* --->		<cfargument name="tree" required="true" type="array" hint="The array">		<cfargument name="md" 	required="true" type="struct" hint="The extends md">		<!--- ************************************************************* --->		<cfscript>			var mdStruct = structnew();			var x=1;						/* secure name */			mdStruct.name = arguments.md.name;			mdStruct.functions = ArrayNew(1);						/* Loop Over Methods */			if( structKeyExists(arguments.md,"functions") and isArray(arguments.md.functions) ){				for(x=1; x lte ArrayLen(arguments.md.functions); x=x+1){					ArrayAppend(mdStruct.functions,arguments.md.functions[x].name);				}				ArraySort(mdStruct.functions,"textnocase","asc");			}						/* Add inheritance info to Tree */			ArrayAppend(arguments.tree, mdStruct);						/* Inheritance Check */			if( structKeyExists(arguments.md,"extends") and arguments.md.extends.name neq "WEB-INF.cftags.component" ){				arguments.tree = inheritanceRecursion(arguments.tree,arguments.md.extends);			}						/* Return inheritance */			return arguments.tree;		</cfscript>	</cffunction>	</cfcomponent>