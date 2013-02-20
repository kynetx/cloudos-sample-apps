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
			CloudRain:createPanel("appTemplate", appMenu);
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
			CloudRain:loadPanel(appContent);
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
			CloudRain:loadPanel(appContent);
			CloudRain:setTitle("See New Title");
		}
	}

  // ------------------------------------------------------------------------
  // Beyond here there be dragons :)
  // ------------------------------------------------------------------------
}
