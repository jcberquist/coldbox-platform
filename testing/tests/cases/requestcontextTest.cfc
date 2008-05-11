<cfcomponent name="requestcontextTest" extends="coldbox.system.extras.testing.baseMXUnitTest" output="false">

	<cffunction name="setUp" returntype="void" access="public" output="false">
		<cfscript>
		//Setup ColdBox Mappings For this Test
		setAppMapping("/coldbox");
		setConfigMapping(ExpandPath(instance.AppMapping & "/config/coldbox.xml.cfm"));
		//Call the super setup method to setup the app.
		super.setup();
		</cfscript>
	</cffunction>
	
	<cffunction name="testgetCollection" returntype="void" access="Public" output="false">
		<cfscript>
			var event = getRequestContext();
			
			assertTrue( isStruct(event.getCollection()) );
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testsetCollection" access="public" returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			
			event.setCollection(structnew());
			
			AssertEquals( structnew(), event.getCollection() );
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testclearCollection" access="public" returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			var test = structnew();
			test.today = now();
			
			event.setCollection(test);
			event.clearCollection();
			
			AssertEquals( structnew(), event.getCollection() );
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testcollectionAppend" access="public" returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			var test = structnew();
			test.today = now();
			
			event.clearCollection();
			event.collectionAppend(test);
			
			AssertEquals( test, event.getCollection() );
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testgetSize" access="public" returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			var test = structnew();
			test.today = now();
			
			event.clearCollection();
			event.collectionAppend(test);
			
			AssertEquals( 1, event.getSize() );
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testgetValue" returntype="void" access="Public" output="false">
		<cfscript>
			var event = getRequestContext();
			var test = structnew();
			test.today = now();
			
			event.clearCollection();
			event.collectionAppend(test);
			
			assertEquals( test.today , event.getValue("today") );
			
			assertEquals( "null", event.getValue("invalidVar", "null") );
			
			assertTrue( isArray(event.getValue("invalidVar", "[array]") ) );
			
			assertTrue( isQuery ( event.getValue("invalidVar", "[query]")  )) ;
			
			assertTrue( isStruct( event.getValue("invalidVar", "[struct]") ) );
			
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testsetValue" access="Public"  output="false" returntype="void">
		<cfscript>
			var event = getRequestContext();
			var test = structnew();
			test.today = now();
			
			event.clearCollection();
			
			event.setValue("test", test.today);
			
			assertEquals(test.today, event.getValue("test") );
			
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testremoveValue" access="Public" output="false" returntype="void">
		<cfscript>
			var event = getRequestContext();
			var test = structnew();
			test.today = now();
			
			event.clearCollection();
			
			event.setValue("test", test.today);
			assertEquals(test.today, event.getValue("test") );
			
			event.removeValue("test");
			assertEquals( false, event.getValue("test", false) );
			
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testvalueExists" returntype="void" access="Public" output="false">
		<cfscript>
			var event = getRequestContext();
			var test = structnew();
			test.today = now();
			
			event.clearCollection();
			
			event.setValue("test", test.today);
			assertTrue( event.valueExists("test") );
			
			event.removeValue("test");
			assertFalse( event.valueExists("test") );
			
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testparamValue" returntype="void" access="Public"	output="false">
		<cfscript>
			var event = getRequestContext();
			var test = structnew();
			test.today = now();
			
			event.clearCollection();
			
			AssertFalse( event.valueExists("test") );
			
			event.paramValue("test", test.today);
			
			assertTrue( event.valueExists("test") );
			
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testCurrentView" access="public"  returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			var view = "vwHome";
			
			event.clearCollection();
			
			event.setView(view);
			assertEquals( view, event.getCurrentView() );
			
			event.clearCollection();
			
			event.setView(view, true);
			assertEquals( view, event.getCurrentView() );
			assertEquals( '', event.getCurrentLayout() );
			
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="testCurrentLayout" access="public" returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			var layout = "layout.pdf";
			
			event.clearCollection();
			
			event.setLayout(layout);
			assertEquals( layout & ".cfm", event.getCurrentLayout() );
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->

	<cffunction name="testgetCurrentEventHandlerAction" access="public"returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			var defaultEvent = "ehTest.doSomething";
			
			event.setValue("event", defaultEvent);
			
			assertEquals( defaultEvent, event.getCurrentEvent() );
			assertEquals( "ehTest", event.getCurrentHandler() );
			assertEquals( "doSomething", event.getCurrentAction() );
			
			defaultEvent = "blog.content.doSomething";
			
			event.setValue("event", defaultEvent);
			
			assertEquals( defaultEvent, event.getCurrentEvent() );
			assertEquals( "content", event.getCurrentHandler() );
			assertEquals( "doSomething", event.getCurrentAction() );
			
			defaultEvent = "blog.content.security.doSomething";
			
			event.setValue("event", defaultEvent);
			
			assertEquals( defaultEvent, event.getCurrentEvent() );
			assertEquals( "security", event.getCurrentHandler() );
			assertEquals( "doSomething", event.getCurrentAction() );
			
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="testoverrideEvent" access="Public"  output="false" returntype="void">
		<cfscript>
			var event = getRequestContext();
			var newEvent = "pio.yea";
			
			event.clearCollection();
			event.setValue("event","blog.dspEntries");
			event.overrideEvent(newEvent);
			
			assertEquals( newEvent , event.getCurrentEvent() );
		</cfscript>
	</cffunction>

	<!--- ************************************************************* --->
	
	<cffunction name="testshowdebugpanel" access="public" returntype="void">
		<cfscript>
			var event = getRequestContext();
			
			event.showDebugPanel(true);
			AssertTrue( event.getDebugPanelFlag() );
			
			event.showDebugPanel(false);
			AssertFalse( event.getDebugPanelFlag() );
			
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="testProxyRequest" access="public" returntype="void" >
		<cfscript>
			var event = getRequestContext();
			
			AssertFalse( event.isProxyRequest() );
			
			event.setProxyRequest();
			AssertTrue( event.isProxyRequest() );
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="testNoRender" access="public" returntype="void">
		<cfscript>
			var event = getRequestContext();
			
			event.NoRender(true);
			AssertTrue( event.isNoRender() );
			
			event.NoRender(false);
			AssertFalse( event.isNoRender() );
			
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="testgetEventName" access="public" returntype="void" output="false">
		<cfscript>
			var event = getRequestContext();
			var test = getController().getSetting("EventName");

			assertEquals( test, event.getEventName() );
			
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="testgetSelf" access="public" output="false" returntype="void">
		<cfscript>
			var event = getRequestContext();
			var test = getController().getSetting("EventName");

			assertEquals( "index.cfm?#test#=", event.getSelf() );
			
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="testEventCacheableEntry" access="public" output="false" returntype="void">
		<cfscript>
			var event = getRequestContext();
			var centry = structnew();
			
			AssertFalse( event.isEventCacheable(), "event cacheable");
			
			centry.cacheable = true;
			centry.test = true;
			
			event.setEventCacheableEntry(centry);
			AssertTrue( event.isEventCacheable(), "event cacheable 2");
			AssertEquals(centry, event.getEventCacheableEntry() );
			
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="testViewCacheableEntry" access="public" output="false" returntype="void">
		<cfscript>
			var event = getRequestContext();
			var centry = structnew();
			
			AssertFalse( event.isViewCacheable(), "view cacheable");
			
			centry.cacheable = true;
			centry.test = true;
			
			event.setViewCacheableEntry(centry);
			AssertTrue( event.isViewCacheable(), "view cacheable 2");
			AssertEquals(centry, event.getViewCacheableEntry() );
			
		</cfscript>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="testRoutedStruct" access="public" output="false" returntype="void">
		<cfscript>
			var event = getRequestContext();
			var routedStruct = structnew();
			
			routedStruct.page = "aboutus";
			routedStruct.day = "13";
			
			event.setRoutedStruct(routedStruct);
			
			AssertEquals(event.getRoutedStruct(),routedStruct);
			
		</cfscript>
	</cffunction>
	

</cfcomponent>