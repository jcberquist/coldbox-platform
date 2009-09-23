<!-----------------------------------------------------------------------********************************************************************************Copyright 2005-2008 ColdBox Framework by Luis Majano and Ortus Solutions, Corpwww.coldboxframework.com | www.luismajano.com | www.ortussolutions.com********************************************************************************Author 	    :	Luis MajanoDate        :	August 21, 2006Description :	This is a cfc that contains method implementations for the base	cfc's eventhandler and plugin. This is an action base controller,	is where all action methods will be placed.	The front controller remains lean and mean.-----------------------------------------------------------------------><cfcomponent hint="This is the layer supertype cfc for all ColdBox related objects." output="false"><!------------------------------------------- CONSTRUCTOR ------------------------------------------->	<cfscript>		// Controller Reference		controller = structNew();		// LogBox Reference		logBox = structnew();		// Instance scope		instance = structnew();		// Unique Instance ID for the object.		instance.__hash = hash(createObject('java','java.lang.System').identityHashCode(this));	</cfscript><!------------------------------------------- PUBLIC METHODS ------------------------------------------->		<!--- Get object Hash --->	<cffunction name="getHash" access="public" hint="Get the instance's unique UUID" returntype="string" output="false">		<cfreturn instance.__hash>	</cffunction>		<!--- Get object Instance --->	<cffunction name="getInstance" access="public" hint="Get the instance of this object" returntype="any" output="false">		<cfreturn instance>	</cffunction>		<!--- Discover fw Locale --->	<cffunction name="getfwLocale" access="public" output="false" returnType="any" hint="Get the default locale string used in the framework. Returns a string">		<cfscript>			var localeStorage = controller.getSetting("LocaleStorage");			var storage = evaluate(localeStorage);			if ( localeStorage eq "" )				$throw("The default settings in your config are blank. Please make sure you create the i18n elements.","","FrameworkSupertype.i18N-DefaultSettingsInvalidException");			if ( not structKeyExists(storage,"DefaultLocale") ){				controller.getPlugin("i18n").setfwLocale(controller.getSetting("DefaultLocale"));			}			return storage["DefaultLocale"];		</cfscript>	</cffunction>	<!------------------------------------------- Private RESOURCE METHODS ------------------------------------------->	<!--- Get a Datasource Object --->	<cffunction name="getDatasource" access="private" output="false" returnType="coldbox.system.beans.DatasourceBean" hint="I will return to you a datasourceBean according to the alias of the datasource you wish to get from the configstruct">		<!--- ************************************************************* --->		<cfargument name="alias" type="string" hint="The alias of the datasource to get from the configstruct (alias property in the config file)">		<!--- ************************************************************* --->		<cfscript>		var datasources = controller.getSetting("Datasources");		//Check for datasources structure		if ( structIsEmpty(datasources) ){			$throw("There are no datasources defined for this application.","","FrameworkSupertype.DatasourceStructureEmptyException");		}				//Try to get the correct datasource.		if ( structKeyExists(datasources, arguments.alias) ){			return CreateObject("component","coldbox.system.beans.DatasourceBean").init(datasources[arguments.alias]);		}				$throw("The datasource: #arguments.alias# is not defined.","Datasources: #structKeyList(datasources)#","FrameworkSupertype.DatasourceNotFoundException");		</cfscript>	</cffunction>	<!--- Get Mail Settings Object --->	<cffunction name="getMailSettings" access="private" output="false" returnType="coldbox.system.beans.MailSettingsBean" hint="I will return to you a mailsettingsBean modeled after your mail settings in your config file.">		<cfreturn CreateObject("component","coldbox.system.beans.MailSettingsBean").init(controller.getSetting("MailServer"),controller.getSetting("MailUsername"),controller.getSetting("MailPassword"), controller.getSetting("MailPort"))>	</cffunction>	<!--- Get a Resource --->	<cffunction name="getResource" access="private" output="false" returnType="any" hint="Facade to i18n.getResource. Returns a string.">		<!--- ************************************************************* --->		<cfargument name="resource" type="any" hint="The resource to retrieve from the bundle.">		<!--- ************************************************************* --->		<cfreturn controller.getPlugin("ResourceBundle").getResource("#arguments.resource#")>	</cffunction>	<!--- Get a Settings Bean --->	<cffunction name="getSettingsBean"  hint="Returns a configBean with all the configuration structure." access="private"  returntype="coldbox.system.beans.ConfigBean"   output="false">		<cfreturn CreateObject("component","coldbox.system.beans.ConfigBean").init(controller.getSettingStructure(false,true))>	</cffunction>	<!------------------------------------------- FRAMEWORK FACADES ------------------------------------------->	<!--- Get Model --->	<cffunction name="getModel" access="private" returntype="any" hint="Create or retrieve model objects by convention" output="false" >		<!--- ************************************************************* --->		<cfargument name="name" 				required="true"  type="string" hint="The name of the model to retrieve">		<cfargument name="useSetterInjection" 	required="false" type="boolean" hint="Whether to use setter injection alongside the annotations property injection. cfproperty injection takes precedence.">		<cfargument name="onDICompleteUDF" 		required="false" type="string"	hint="After Dependencies are injected, this method will look for this UDF and call it if it exists. The default value is onDIComplete">		<cfargument name="debugMode" 			required="false" type="boolean" hint="Debugging Mode or not">		<cfargument name="stopRecursion"		required="false" type="string"  hint="A comma-delimmited list of stoprecursion classpaths.">		<!--- ************************************************************* --->		<cfreturn getPlugin("BeanFactory").getModel(argumentCollection=arguments)>	</cffunction>		<!--- Populate a model object from the request Collection --->	<cffunction name="populateModel" access="private" output="false" returntype="Any" hint="Populate a named or instantiated model (java/cfc) from the request collection items">		<!--- ************************************************************* --->		<cfargument name="model" 			required="true"  type="any" 	hint="The name of the model to get and populate or the acutal model object. If you already have an instance of a model, then use the populateBean() method">		<cfargument name="scope" 			required="false" type="string"  default=""   hint="Use scope injection instead of setters population. Ex: scope=variables.instance."/>		<cfargument name="trustedSetter"  	required="false" type="boolean" default="false" hint="If set to true, the setter method will be called even if it does not exist in the bean"/>		<cfargument name="include"  		required="false" type="string"  default="" hint="A list of keys to include in the population">		<cfargument name="exclude"  		required="false" type="string"  default="" hint="A list of keys to exclude in the population">		<!--- ************************************************************* --->		<cfreturn getPlugin("BeanFactory").populateModel(argumentCollection=arguments)>	</cffunction>	<!--- View Rendering Facades --->	<cffunction name="renderView"         access="private" hint="Facade to plugin's render view." output="false" returntype="Any">		<!--- ************************************************************* --->		<cfargument name="view" required="true" type="string">		<cfargument name="cache" 					required="false" type="boolean" default="false" hint="True if you want to cache the view.">		<cfargument name="cacheTimeout" 			required="false" type="string"  default=""		hint="The cache timeout">		<cfargument name="cacheLastAccessTimeout" 	required="false" type="string"  default="" 		hint="The last access timeout">		<!--- ************************************************************* --->		<cfreturn controller.getPlugin("Renderer").renderView(argumentCollection=arguments)>	</cffunction>	<cffunction name="renderExternalView" access="private" hint="Facade to plugins' render external view." output="false" returntype="Any">		<!--- ************************************************************* --->		<cfargument name="view" required="true" type="string">		<!--- ************************************************************* --->		<cfreturn controller.getPlugin("Renderer").renderExternalView(arguments.view)>	</cffunction>	<!--- Plugin Facades --->	<cffunction name="getMyPlugin" access="private" hint="Facade" returntype="any" output="false">		<!--- ************************************************************* --->		<cfargument name="plugin" 		type="any"  	required="true" hint="The plugin name as a string" >		<cfargument name="newInstance"  type="boolean"  required="false" default="false">		<!--- ************************************************************* --->		<cfreturn controller.getPlugin(arguments.plugin, true, arguments.newInstance)>	</cffunction>	<cffunction name="getPlugin"   access="private" hint="Facade" returntype="any" output="false">		<!--- ************************************************************* --->		<cfargument name="plugin"       type="any" hint="The Plugin object's name to instantiate, as a string" >		<cfargument name="customPlugin" type="boolean" required="false" default="false">		<cfargument name="newInstance"  type="boolean" required="false" default="false">		<!--- ************************************************************* --->		<cfreturn controller.getPlugin(argumentCollection=arguments)>	</cffunction>	<!--- Interceptor Facade --->	<cffunction name="getInterceptor" access="private" output="false" returntype="any" hint="Get an interceptor">		<!--- ************************************************************* --->		<cfargument name="interceptorName" 	required="false" type="string" hint="The name of the interceptor to search for"/>		<cfargument name="deepSearch" 		required="false" type="boolean" default="false" hint="By default we search the cache for the interceptor reference. If true, we search all the registered interceptor states for a match."/>		<!--- ************************************************************* --->		<cfreturn controller.getInterceptorService().getInterceptor(argumentCollection=arguments)>	</cffunction>		<!--- Announce Interception --->	<cffunction name="announceInterception" access="private" returntype="void" hint="Announce an interception to the system." output="false" >		<cfargument name="state" 			required="true"  type="string" hint="The interception state to execute">		<cfargument name="interceptData" 	required="false" type="struct" default="#structNew()#" hint="A data structure used to pass intercepted information.">		<cfset controller.getInterceptorService().processState(argumentCollection=arguments)>	</cffunction>		<!---Cache Facades --->	<cffunction name="getColdboxOCM" access="private" output="false" returntype="any" hint="Get ColdboxOCM: coldbox.system.cache.CacheManager">		<cfreturn controller.getColdboxOCM()/>	</cffunction>	<!--- Setting Facades --->	<cffunction name="getSettingStructure"  hint="Facade" access="private"  returntype="struct"   output="false">		<!--- ************************************************************* --->		<cfargument name="FWSetting"  	type="boolean" 	 required="false"  default="false">		<cfargument name="DeepCopyFlag" type="boolean"   required="false"  default="false">		<!--- ************************************************************* --->		<cfreturn controller.getSettingStructure(argumentCollection=arguments)>	</cffunction>	<cffunction name="getSetting" 			hint="Facade" access="private" returntype="any"      output="false">		<!--- ************************************************************* --->		<cfargument name="name" 	    type="string"   required="true">		<cfargument name="FWSetting"  	type="boolean" 	required="false"  default="false">		<!--- ************************************************************* --->		<cfreturn controller.getSetting(argumentCollection=arguments)>	</cffunction>	<cffunction name="settingExists" 		hint="Facade" access="private" returntype="boolean"  output="false">		<!--- ************************************************************* --->		<cfargument name="name" 		type="string"  	required="true">		<cfargument name="FWSetting"  	type="boolean"  required="false"  default="false">		<!--- ************************************************************* --->		<cfreturn controller.settingExists(argumentCollection=arguments)>	</cffunction>	<cffunction name="setSetting" 		    hint="Facade" access="private"  returntype="void"     output="false">		<!--- ************************************************************* --->		<cfargument name="name"  type="string" required="true" >		<cfargument name="value" type="any" required="true" >		<!--- ************************************************************* --->		<cfset controller.setSetting(argumentCollection=arguments)>	</cffunction>	<!--- Event Facades --->	<cffunction name="setNextEvent" access="private" returntype="void" hint="Facade"  output="false">		<!--- ************************************************************* --->		<cfargument name="event"  			type="string"  required="false" default="#getSetting("DefaultEvent")#" hint="The name of the event to run.">		<cfargument name="queryString"  	type="string"  required="false" default="" hint="The query string to append, if needed.">		<cfargument name="addToken"		 	type="boolean" required="false" default="false"	hint="Whether to add the tokens or not. Default is false">		<cfargument name="persist" 			type="string"  required="false" default="" hint="What request collection keys to persist in the relocation">		<cfargument name="varStruct" 		type="struct"  required="false" default="#structNew()#" hint="A structure key-value pairs to persist.">		<cfargument name="ssl"				type="boolean" required="false" default="false"	hint="Whether to relocate in SSL or not, only used when in SES mode.">		<!--- ************************************************************* --->		<cfset controller.setNextEvent(argumentCollection=arguments)>	</cffunction>	<cffunction name="setNextRoute" access="private" returntype="void" hint="I Set the next ses route to relocate to. This method pre-pends the baseURL"  output="false">		<!--- ************************************************************* --->		<cfargument name="route"  		required="true"	 type="string" hint="The route to relocate to, do not prepend the baseURL or /.">		<cfargument name="persist" 		required="false" type="string" default="" hint="What request collection keys to persist in the relocation">		<cfargument name="varStruct" 	required="false" type="struct" hint="A structure key-value pairs to persist.">		<cfargument name="addToken"		required="false" type="boolean" default="false"	hint="Wether to add the tokens or not. Default is false">		<cfargument name="ssl"			required="false" type="boolean" default="false"	hint="Whether to relocate in SSL or not">		<!--- ************************************************************* --->		<cfset controller.setNextRoute(argumentCollection=arguments)>	</cffunction>	<cffunction name="runEvent" 	access="private" returntype="any" hint="Facade to controller's runEvent() method." output="false">		<!--- ************************************************************* --->		<cfargument name="event" 			type="string" required="no" default="">		<cfargument name="prepostExempt" 	type="boolean" required="false" default="false" hint="If true, pre/post handlers will not be fired.">		<cfargument name="private" 		 	type="boolean" required="false" default="false" hint="Execute a private event or not, default is false"/>		<!--- ************************************************************* --->		<cfset var refLocal = structnew()>		<cfset reflocal.results = controller.runEvent(argumentCollection=arguments)>		<cfif structKeyExists(refLocal,"results")>			<cfreturn refLocal.results>		</cfif>	</cffunction>		<!--- Flash Perist variables. --->	<cffunction name="persistVariables" access="private" returntype="void" hint="Persist variables for flash redirections" output="false" >		<!--- ************************************************************* --->		<cfargument name="persist" 		required="false" type="string" default="" hint="What request collection keys to persist in the relocation">		<cfargument name="varStruct" 	required="false" type="struct" hint="A structure key-value pairs to persist.">		<!--- ************************************************************* --->		<cfset controller.persistVariables(argumentCollection=arguments)>	</cffunction>		<!--- Debug Mode Facades --->	<cffunction name="getDebugMode" access="private" hint="Facade to get your current debug mode" returntype="boolean"  output="false">		<cfreturn controller.getDebuggerService().getDebugMode()>	</cffunction>	<cffunction name="setDebugMode" access="private" hint="Facade to set your debug mode" returntype="void"  output="false">		<cfargument name="mode" type="boolean" required="true" >		<cfset controller.getDebuggerService().setDebugMode(arguments.mode)>	</cffunction>		<!--- Controller Accessor/Mutators --->	<cffunction name="getController" access="private" output="false" returntype="any" hint="Get controller: coldbox.system.Controller">
		<cfreturn variables.controller/>
	</cffunction>		<!--- LogBox Accessor/Mutator --->	<cffunction name="getLogBox" access="private" returntype="coldbox.system.logging.LogBox" output="false" hint="Get a reference to LogBox">
		<cfreturn variables.logBox>
	</cffunction><!------------------------------------------- UTILITY METHODS ------------------------------------------->		<!--- locateFilePath --->
	<cffunction name="locateFilePath" output="false" access="private" returntype="string" hint="Locate the real path location of a file in a coldbox application. 3 checks: 1) inside of coldbox app, 2) expand the path, 3) Absolute location. If path not found, it returns an empty path">
		<cfargument name="pathToCheck" type="string"  required="true" hint="The path to check"/>		<cfscript>			var foundPath = "";			var appRoot = controller.getAppRootPath();						//Check 1: Inside of App Root			if ( fileExists(appRoot & arguments.pathToCheck) ){				foundPath = appRoot & arguments.pathToCheck;			}			//Check 2: Expand the Path			else if( fileExists( ExpandPath(arguments.pathToCheck) ) ){				foundPath = ExpandPath( arguments.pathToCheck );			}			//Check 3: Absolute Path			else if( fileExists( arguments.pathToCheck ) ){				foundPath = arguments.pathToCheck;			}						//Return 			return foundPath;					</cfscript>
	</cffunction>		<!--- locateFilePath --->	<cffunction name="locateDirectoryPath" output="false" access="private" returntype="string" hint="Locate the real path location of a directory in a coldbox application. 3 checks: 1) inside of coldbox app, 2) expand the path, 3) Absolute location. If path not found, it returns an empty path">		<cfargument name="pathToCheck" type="string"  required="true" hint="The path to check"/>		<cfscript>			var foundPath = "";			var appRoot = controller.getAppRootPath();						//Check 1: Inside of App Root			if ( directoryExists(appRoot & arguments.pathToCheck) ){				foundPath = appRoot & arguments.pathToCheck;			}			//Check 2: Expand the Path			else if( directoryExists( ExpandPath(arguments.pathToCheck) ) ){				foundPath = ExpandPath( arguments.pathToCheck );			}			//Check 3: Absolute Path			else if( directoryExists( arguments.pathToCheck ) ){				foundPath = arguments.pathToCheck;			}						//Return 			return foundPath;					</cfscript>	</cffunction>		<!--- addAsset --->	<cffunction name="addAsset" output="false" access="private" returntype="void" hint="Add a js/css asset(s) to the html head section. You can also pass in a list of assets.">		<cfargument name="asset" type="any" required="true" hint="The asset to load, only js or css files. This can also be a comma delimmited list."/>		<cfscript>			var sb = createObject("java","java.lang.StringBuffer").init('');			var x = 1;			var thisAsset = "";			var event = controller.getRequestService().getContext();						// request assets storage			event.paramValue(name="cbox_assets",value="",private=true);						for(x=1; x lte listLen(arguments.asset); x=x+1){				thisAsset = listGetAt(arguments.asset,x);				// Is asset already loaded				if( NOT listFindNoCase(event.getValue(name="cbox_assets",private=true),thisAsset) ){										// Load Asset					if( listLast(thisAsset,".") eq "js" ){						sb.append('<script src="#thisAsset#" type="text/javascript" language="javascript"></script>');					}					else{						sb.append('<link href="#thisAsset#" type="text/css" rel="stylesheet" />');					}										// Store It as Loaded					event.setValue(name="cbox_assets",value=listAppend(event.getValue(name="cbox_assets",private=true),thisAsset),private=true);										//Load it					$htmlhead(sb.toString());				}			}		</cfscript>	</cffunction>		<!--- Include UDF --->	<cffunction name="includeUDF" access="private" hint="Injects a UDF Library (*.cfc or *.udf) into the target object.  It does not however, put the mixins on any of the cfc scopes. Therefore they can only be called internally." output="false" returntype="void">		<!--- ************************************************************* --->		<cfargument name="udflibrary" required="true" type="string" hint="The UDF library to inject.">		<!--- ************************************************************* --->		<cfscript>			var UDFFullPath = ExpandPath(arguments.udflibrary);			var UDFRelativePath = ExpandPath("/" & getController().getSetting("AppMapping") & "/" & arguments.udflibrary);			/* Relative Checks First */			if( fileExists(UDFRelativePath) ){				$include("/#getController().getSetting("appMapping")#/#arguments.udflibrary#");			}			else if( fileExists(UDFRelativePath & ".cfc") ){				$include("/#getController().getSetting("appMapping")#/#arguments.udflibrary#.cfc");			}			else if( fileExists(UDFRelativePath & ".cfm") ){				$include("/#getController().getSetting("appMapping")#/#arguments.udflibrary#.cfm");			}			/* Absolute Checks */			else if( fileExists(UDFFullPath) ){				$include("#udflibrary#");			}			else if( fileExists(UDFFullPath & ".cfc") ){				$include("#udflibrary#.cfc");			}			else if( fileExists(UDFFullPath & ".cfm") ){				$include("#udflibrary#.cfm");			}			else{				$throw(message="Error loading UDFLibraryFile: #arguments.udflibrary#",					  detail="The UDF library was not found.  Please make sure you verify the file location.",					  type="FrameworkSupertype.UDFLibraryNotFoundException");			}		</cfscript>	</cffunction>		<!--- CFLOCATION Facade --->	<cffunction name="relocate" access="private" hint="Facade for cflocation" returntype="void">		<cfargument name="url" 		required="true" 	type="string">		<cfargument name="addtoken" required="false" 	type="boolean" default="false">		<cfargument name="postProcessExempt"  type="boolean" required="false" default="false" hint="Do not fire the postProcess interceptors">		<cfset controller.relocate(argumentCollection=arguments)>	</cffunction>		<!--- cfhtml head facade --->	<cffunction name="$htmlhead" access="private" returntype="void" hint="Facade to cfhtmlhead" output="false" >		<!--- ************************************************************* --->		<cfargument name="content" required="true" type="string" hint="The content to send to the head">		<!--- ************************************************************* --->		<cfhtmlhead text="#arguments.content#">			</cffunction>		<!--- Throw Facade --->	<cffunction name="$throw" access="private" hint="Facade for cfthrow" output="false">		<!--- ************************************************************* --->		<cfargument name="message" 	type="string" 	required="yes">		<cfargument name="detail" 	type="string" 	required="no" default="">		<cfargument name="type"  	type="string" 	required="no" default="Framework">		<!--- ************************************************************* --->		<cfthrow type="#arguments.type#" message="#arguments.message#"  detail="#arguments.detail#">	</cffunction>		<!--- Dump facade --->	<cffunction name="$dump" access="private" hint="Facade for cfmx dump" returntype="void">		<cfargument name="var" required="yes" type="any">		<cfargument name="isAbort" type="boolean" default="false" required="false" hint="Abort also"/>		<cfdump var="#var#">		<cfif arguments.isAbort><cfabort></cfif>	</cffunction>		<!--- Rethrow Facade --->	<cffunction name="$rethrow" access="private" returntype="void" hint="Rethrow facade" output="false" >		<cfargument name="throwObject" required="true" type="any" hint="The cfcatch object">		<cfthrow object="#arguments.throwObject#">	</cffunction>		<!--- Abort Facade --->	<cffunction name="$abort" access="private" hint="Facade for cfabort" returntype="void" output="false">		<cfabort>	</cffunction>		<!--- Include Facade --->	<cffunction name="$include" access="private" hint="Facade for cfinclude" returntype="void" output="false">		<cfargument name="template" type="string">		<cfinclude template="#template#">	</cffunction></cfcomponent>