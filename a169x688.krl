ruleset a169x688 {
  meta {
    name "Hello Guest Application"
    description <<
      myCloud Hello Guest Application
      Copyright 2012 Kynetx, All Rights Reserved

      While the classic Hello World application should be run by an
      authenticated user, this version of Hello, World is intended to
      be run by an unauthenticated user. The main difference is that
      the initial event raised to the application is
      web:cloudAppSelectedAnonymous, instead of web:cloudAppSelected.
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
  // Test: https://mycloud.kynetx.com/#!/app/a169x688/show

  rule appHelloWorld_Selected {
    select when web cloudAppSelectedAnonymous
    fired {
      raise cloudos event appReadyToLoad
        with appName = "Hello Guest"
        and  appRID  = thisRID
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
        Hello, Guest!
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
  // Beyond here there be dragons :)
  // ------------------------------------------------------------------------
}
