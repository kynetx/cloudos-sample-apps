ruleset a169x690 {
  meta {
    name "myCloud Subscription Example"
    description <<
      myCloud Subscription Example
      Copyright 2012 Kynetx, All Rights Reserved

      To exercise this subscribe (and unsubscribe) example you will
      need to install this ruleset in two separate Personal
      Clouds. Note: To simplify this example the doorbell ECI will need
      to be hardcode in the appSubscribe_cloudAppCommand_subscribe rule.
    >>

    author "Ed Orcutt" logging on

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
  // Test: https://mycloud.kynetx.com/#!/app/a169x690/show

  rule appSubscribe_Selected {
    select when web cloudAppSelected
    pre {
      appMenu = [
        { "label"  : "Refresh",
          "action" : "refresh" },
        { "label"  : "Subscribe",
          "action" : "subscribe" }
      ];
    }
    fired {
      raise cloudos event appReadyToLoad
        with appName = "Subscription Example"
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

  rule appSubscribe_Loaded {
    select when explicit appLoaded
    pre {
      appContentSelector = event:attr("appContentSelector");


      // --------------------------------------------
      // retrieve all active subscriptions

      allSubs = CloudOS:getAllSubscriptions();

      subHTML = allSubs.keys().map(function(backChannel) {
        namespace    = allSubs{[backChannel, "namespace"]};
        channelName  = allSubs{[backChannel, "channelName"]};
        relationship = allSubs{[backChannel, "relationship"]};
        eventChannel = allSubs{[backChannel, "eventChannel"]};
        subAttrs     = allSubs{[backChannel, "subAttrs"]};
        approveAttrs = allSubs{[backChannel, "approveAttrs"]};

        foo = <<
          <p style="color:#000000;margin-left:20px;"><strong>space/name/type:</strong> #{namespace} / #{channelName} / #{relationship}
          <a href="#!/app/#{thisRID}/unsubscribe&backChannel=#{backChannel}" class="btn btn-mini btn-danger" style="line-height:12px;">Unsubscribe</a></br>
          <strong>eventChannel:</strong> #{eventChannel}</br>
          <strong>backChannel:</strong> #{backChannel}</br>
          <strong>subAttrs:</strong> #{subAttrs}</br>
          <strong>approveAttrs:</strong> #{approveAttrs}</p>
        >>;
        foo
      }).join(" ");

      // --------------------------------------------
      // retrieve all subscriptions pending approval

      allPending = CloudOS:getAllPendingApproval();

      pendHTML = allPending.keys().map(function(eventChannel) {
        namespace    = allPending{[eventChannel, "namespace"]};
        channelName  = allPending{[eventChannel, "channelName"]};
        relationship = allPending{[eventChannel, "relationship"]};
        subAttrs     = allPending{[eventChannel, "subAttrs"]};
        foo = <<
          <p style="color:#000000;margin-left:20px;"><strong>space/name/type:</strong> #{namespace} / #{channelName} / #{relationship}
          <a href="#!/app/#{thisRID}/approveSubscribe&eventChannel=#{eventChannel}" class="btn btn-mini btn-danger" style="line-height:12px;">Approve</a>
          <a href="#!/app/#{thisRID}/rejectSubscribe&eventChannel=#{eventChannel}" class="btn btn-mini btn-danger" style="line-height:12px;">Reject</a></br>
          <strong>eventChannel:</strong> #{eventChannel}</br>
          <strong>subAttrs:</strong> #{subAttrs}</br>
        >>;
        foo
      }).join(" ");

      // --------------------------------------------
      // retrieve all subscription request

      allRequest = CloudOS:getAllPendingSubscriptions();

      requestHTML = allRequest.keys().map(function(backChannel) {
        namespace    = allRequest{[backChannel, "namespace"]};
        channelName  = allRequest{[backChannel, "channelName"]};
        relationship = allRequest{[backChannel, "relationship"]};
        subAttrs     = allRequest{[backChannel, "subAttrs"]};

        foo = <<
          <p style="color:#000000;margin-left:20px;"><strong>space/name/type:</strong> #{namespace} / #{channelName} / #{relationship}</br>
          <strong>backChannel:</strong> #{backChannel}</br>
          <strong>subAttrs:</strong> #{subAttrs}</p>
        >>;
        foo
      }).join(" ");

      appContent = <<
        <h4 style="margin-left:20px;">Active Subscriptions</h4>
        #{subHTML}

        <h4 style="margin-left:20px;">Subscriptions Pending Approval</h4>
        #{pendHTML}

        <h4 style="margin-left:20px;">Pending Subscriptions Request</h4>
        #{requestHTML}
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

  rule appSubscribe_Shown {
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
  rule appSubscribe_cloudAppCommand_refresh {
    select when web cloudAppAction action re/refresh/
    {
      cloudUI:setHash("#!/app/"+thisRID+"/show");
    }
  }

  // ------------------------------------------------------------------------
  rule appSubscribe_cloudAppCommand_subscribe {
    select when web cloudAppAction action re/^subscribe$/
    pre {
      appContentSelector = cloudUI:cloudAppContentSelector(thisRID);

      appContent = <<
        Subscription Request Sent. Refresh for status.
      >>;

      doorbell = "REDACTED";
    }
    {
      replace_inner(appContentSelector, appContent);
      cloudUI:hideSpinner();
    }
		always {
		  raise system event subscribe
				with namespace = "DocExample"
			  and  channelName = "SimpleSubscribe"
				and  relationship = "ping-pong"
				and  targetChannel = doorbell
				and  subAttrs = {"name": "Ed Orcutt", "age": "43"}
				and  _api = "sky";
		}
  }

  // ------------------------------------------------------------------------
  rule appSubscribe_cloudAppCommand_approveSubscribe {
    select when web cloudAppAction action re/approveSubscribe/
    pre {
		  eventChannel= event:attr("eventChannel");
		}
		{
		  notify("Approve subscribe", eventChannel) with sticky = true;
		  cloudUI:hideSpinner();
		}
		always {
		  raise cloudos event subscriptionRequestApproved
			  with eventChannel = eventChannel
				and  approveAttrs = {"name": "Fred Wilson" , "age": "22" }
				and  _api = "sky";
		}
	}

  // ------------------------------------------------------------------------
  rule appSubscribe_cloudAppCommand_rejectSubscribe {
    select when web cloudAppAction action re/rejectSubscribe/
    pre {
		  eventChannel= event:attr("eventChannel");
		}
		{
		  notify("Reject subscribe", eventChannel) with sticky = true;
		  cloudUI:hideSpinner();
		}
		always {
		  raise cloudos event subscriptionRequestRejected
			  with eventChannel = eventChannel
				and  _api = "sky";
		}
	}

  // ------------------------------------------------------------------------
  rule appSubscribe_cloudAppCommand_unsubscribe {
    select when web cloudAppAction action re/unsubscribe/
    pre {
		  backChannel= event:attr("backChannel");
		}
		{
		  notify("Unsubscribe", backChannel) with sticky = true;
		  cloudUI:hideSpinner();
		}
		always {
		  raise cloudos event unsubscribe
			  with backChannel = backChannel
				and  _api = "sky";
		}
	}

  // ------------------------------------------------------------------------
  // Beyond here there be dragons :)
  // ------------------------------------------------------------------------
}
