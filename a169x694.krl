ruleset a169x694 {
  meta {
    name "neuAppTemplate"
    description <<
      myCloud appication template
      Copyright 2012 Kynetx, All Rights Reserved
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
  rule appTemplate_Selected {
    select when web cloudAppSelected
           or   web cloudAppAction
    pre {
      appMenu = [
        { "label"  : "First",
          "action" : "first" },
        { "label"  : "More",
          "action" : "more" }
      ];
    }
    {
      // notify("appTemplate", "Selected, ready to load") with sticky = true;
      cloudUI:createAppPanel(thisRID, "appTemplate", appMenu);
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
      cloudUI:loadAppPanel(thisRID, appContent);
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
      cloudUI:loadAppPanel(thisRID, appContent);
    }
  }

  // ------------------------------------------------------------------------
  // Beyond here there be dragons :)
  // ------------------------------------------------------------------------
}
