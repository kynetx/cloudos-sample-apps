ruleset a169x689 {
  meta {
    name "Application Menu"
    description <<
      myCloud Sample Application Menu
      Copyright 2012 Kynetx, All Rights Reserved

      You can add items to the application menu. This sample adds two
      new items. The menu items labels and associated actions are
      specified in the appMenu hash and passed as attributes to
      cloudos:appReadyToLoad. To respond to the events when they are
      raised add rules for web:cloudAppAction.
    >>
    author "Ed Orcutt"
    logging on

    use module a169x625 alias CloudOS
    use module a169x664 alias cloudUI
  }

  global {
    thisRID = meta:rid();
  }

  // ------------------------------------------------------------------------
  // Application has been selected to be run on the myCloud dashboard
  // Raise event to CloudOS to allocate resources for this application
  // 
  // Test: https://mycloud.kynetx.com/#!/app/a169x689/show

  rule appHelloWorld_Selected {
    select when web cloudAppSelected
    pre {
      appMenu = [
        { "label"  : "Refresh",
          "action" : "refresh" },
        { "label"  : "More",
          "action" : "more" }
      ];
    }
    fired {
      raise cloudos event appReadyToLoad
        with appName = "Application Menu"
        and  appRID  = thisRID
        and  appMenu = appMenu
        and  _api = "sky";
    }
  }

  // ------------------------------------------------------------------------
  // CloudOS has allocated resources for this application and raised
  // the explicit:appLoaded event in the calling Personal Cloud
  //
  // Insert your application content inside appContentSelector
  //
  // Raise event cloudos:appReadyToShow to signal CloudOS to display content

  rule appHelloWorld_Loaded {
    select when explicit appLoaded
    pre {
      appContentSelector = event:attr("appContentSelector");

      appContent = <<
        Hello, World!</br>
        Check out the new menu items!
      >>;
    }
    {
      replace_inner(appContentSelector, appContent);
    }
    fired {
      raise cloudos event appReadyToShow
        with appRID  = thisRID
        and  _api = "sky";
    }
  }

  // ------------------------------------------------------------------------
  // CloudOS has made your application visible
  // Hide the spinner

  rule appHelloWorld_Shown {
    select when explicit appShown
    {
      cloudUI:hideSpinner();
    }
    fired {
      raise cloudos event cloudAppReady
        with appRID  = thisRID
        and  _api = "sky";
    }
  }

  // ------------------------------------------------------------------------
  rule appHelloWorld_cloudAppCommand_refresh {
    select when web cloudAppAction action re/refresh/
    {
      cloudUI:setHash("#!/app/"+thisRID+"/show");
    }
  }

  // ------------------------------------------------------------------------
  rule appHelloWorld_cloudAppCommand_more {
    select when web cloudAppAction action re/more/
    pre {
      appContentSelector = cloudUI:cloudAppContentSelector(thisRID);

      appContent = <<
        More Hello, World!</br>
        Select Refresh menu item to return.
      >>;
    }
    {
      replace_inner(appContentSelector, appContent);
      cloudUI:hideSpinner();
    }
  }

  // ------------------------------------------------------------------------
  // Beyond here there be dragons :)
  // ------------------------------------------------------------------------
}
