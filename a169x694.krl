ruleset a169x694 {
	meta {
		name "neuAppTemplate"
		description <<
			myCloud appication template
      Copyright 2012 Kynetx, All Rights Reserved
		>>
		author "Ed Orcutt"
		logging on

    use module a169x701 alias CloudRain
	}

	global {
    thisRID = meta:rid();
	}

  // ------------------------------------------------------------------------
	rule appTemplate_Selected {
		select when web cloudAppSelected
		       or   web cloudAppAction
		pre {
		  appMenu = [
			  { "label"  : "More",
				  "action" : "more" }
			];
		}
		{
			CloudRain:createAppPanel(thisRID, "appTemplate", appMenu);
		}
	}

  // ------------------------------------------------------------------------
	rule appTemplate_Created {
	  select when web cloudAppSelected
		       or   web cloudAppAction action re/first/
		pre {
		  appContent = <<
			  Hello, World!
			>>;
		}
		{
			CloudRain:loadAppPanel(thisRID, appContent);
		}
	}

  // ------------------------------------------------------------------------
	rule appTemplate_more {
	  select when web cloudAppAction action re/more/
		pre {
		  appContent = <<
			  More Hello!
			>>;
		}
		{
			CloudRain:loadAppPanel(thisRID, appContent);
			CloudRain:setAppTitle(thisRID, "See New Title");
		}
	}

  // ------------------------------------------------------------------------
  // Beyond here there be dragons :)
  // ------------------------------------------------------------------------
}
