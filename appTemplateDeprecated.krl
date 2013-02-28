ruleset a169x674 {
	meta {
		name "appTemplate"
		description <<
			myCloud appication template

      Copyright 2012 Kynetx, All Rights Reserved
		>>
		author "Ed Orcutt"
		logging on

    use module a169x625 alias CloudOS
		use module a169x664 alias cloudUI
		use module a169x676 alias pds
	}

	global {
    thisRID = meta:rid();
	}

  // ------------------------------------------------------------------------
	rule appTemplate_Selected {
		select when web cloudAppSelected
		       or   web cloudAppSelectedAnonymous
		pre {
		  appMenu = [
			  { "label"  : "Modal Demo",
				  "action" : "foome" },
				{ "label"  : "Barit",
				  "action" : "barme" }
			];
		}
		{
		  notify("appTemplate", "Selected, ready to load") with sticky = true;
		}
		fired {
		  raise cloudos event appReadyToLoad
			  with appName = "appTemplate"
				and  appRID  = thisRID
				and  appMenu = appMenu
			  and  _api = "sky";
		}
	}

  // ------------------------------------------------------------------------
	rule appTemplate_Loaded_Anonymous {
	  select when web cloudAppSelectedAnonymous
		       then explicit appLoaded
		pre {
		  appContentSelector = event:attr("appContentSelector");

			appContent = <<
			  Hello Guest, please login.
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
	rule appTemplate_Loaded {
	  select when web cloudAppSelected
		       then explicit appLoaded
		pre {
		  appContentSelector = event:attr("appContentSelector");

			appContent = <<
			  <p><a class="btn btn-primary" href="#!/app/#{thisRID}/hello">Click me!</a></p>

        <form id="formAppTemplate" class="form-horizontal">
          <fieldset>
            <div class="control-group">
              <label class="control-label" for="toyFirstName">First Name</label>
              <div class="controls">
                <input type="text" name="toyFirstName" value="#{pds:get_item('appTemplate', 'toyFirstName')}">
              </div>
            </div>
            <div class="control-group">
              <label class="control-label" for="toyLastName">Last Name</label>
              <div class="controls">
                <input type="text" name="toyLastName" value="#{pds:get_item('appTemplate', 'toyLastName')}">
              </div>
            </div>
            <div class="form-actions">
              <button type="submit" class="btn btn-primary">Save Changes</button>
            </div>
          </fieldset>
        </form>

				<div id="modalDemo" class="modal hide fade">
				  <div class="modal-header">
					  <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
						<h3>Modal Demo Header</h3>
					</div>
					<div class="modal-body">
					  <p>One fine body ...</p>
					</div>
					<div class="modal-footer">
						<button class="btn btn-primary">Close</button>
					</div>
				</div>
			>>;
		}
		{
		  // notify("appTemplate", "Loaded, ready to show") with sticky = true;
			replace_inner(appContentSelector, appContent);
			CloudOS:skyWatchSubmit("#formAppTemplate", "");

			emit <<
			  $K('#modalDemo button').click(function() {
				  $K('#modalDemo').modal('hide');
				});

        // Change URL fragment back to after modal closes
        $K('#modalDemo').on('hidden', function() {
          self.document.location.hash = '!/app/'+thisRID+'/show';
        });
			>>;
		}
		fired {
		  raise cloudos event appReadyToShow
				with appRID  = thisRID
			  and  _api = "sky";
		}
	}

  // ------------------------------------------------------------------------
	rule appTemplate_Shown {
		select when explicit appShown
		{
		  notify("appTemplate", "Shown, app ready") with sticky = true;
		  cloudUI:hideSpinner();
		}
		fired {
		  raise cloudos event cloudAppReady
				with appRID  = thisRID
			  and  _api = "sky";
		}
	}

  // ------------------------------------------------------------------------
	rule appTemplate_formSubmit {
	  select when web submit "#formAppTemplate"
		pre {
		  mapvalues = event:attrs();
		}
		{
		  notify("appTemplate_formSubmit", "hello neo ...") with sticky = true;
		  cloudUI:hideSpinner();
		}
		always {
		  raise pds event new_map_available
			  with namespace = "appTemplate"
				and  mapvalues = mapvalues
				and  _api = "sky";
		}
	}

  // ------------------------------------------------------------------------
	rule appTemplate_hello {
	  select when web cloudAppAction action re/hello/
		pre {
		}
		{
		  notify("appTemplate", "You clicked me!") with sticky = true;
		  cloudUI:hideSpinner();
		}
	}

  // ------------------------------------------------------------------------
	rule appTemplate_foome {
	  select when web cloudAppAction action re/foome/
		pre {
		}
		{
		  notify("appTemplate", "Here's Foomore") with sticky = true;
			emit <<
			  $K('#modalDemo').modal('show');
			>>;
		  cloudUI:hideSpinner();
		}
	}

  // ------------------------------------------------------------------------
	rule appTemplate_barme {
	  select when web cloudAppAction action re/barme/
		pre {
		}
		{
		  notify("appTemplate", "Here's Barit") with sticky = true;
		  cloudUI:hideSpinner();
		}
	}

  // ------------------------------------------------------------------------
  // Beyond here there be dragons :)
  // ------------------------------------------------------------------------
}
