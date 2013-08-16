ruleset a169x741 {
	meta {
		name "CloudOSsimpleCRUD"
		description <<
			CloudOS Read & Write to PDS
      Copyright 2013 Kynetx, All Rights Reserved
		>>
		author "Ed Orcutt"
		logging on

    use module a169x701 alias CloudRain
		use module a169x676 alias pds
	}

  // ------------------------------------------------------------------------
	rule appCRUD_Selected {
		select when web cloudAppSelected
		       or   web cloudAppAction
		pre {
		  appMenu = [];
		}
		{
			CloudRain:createPanel("appCRUD", appMenu);
		}
	}

  // ------------------------------------------------------------------------
	rule appCRUD_Created {
	  select when web cloudAppSelected
		pre {
			appContent = <<
        <form id="formAppCRUD" class="form-horizontal">
          <fieldset>
            <div class="control-group">
              <label class="control-label" for="toyFirstName">First Name</label>
              <div class="controls">
                <input type="text" name="toyFirstName" value="#{pds:get_item('appCRUD', 'toyFirstName')}">
              </div>
            </div>
            <div class="control-group">
              <label class="control-label" for="toyLastName">Last Name</label>
              <div class="controls">
                <input type="text" name="toyLastName" value="#{pds:get_item('appCRUD', 'toyLastName')}">
              </div>
            </div>
            <div class="form-actions">
              <button type="submit" class="btn btn-primary">Save Changes</button>
            </div>
          </fieldset>
        </form>
			>>;
		}
		{
			CloudRain:loadPanel(appContent);
			CloudRain:skyWatchSubmit("#formAppCRUD", meta:eci());
		}
	}

  // ------------------------------------------------------------------------
	rule appCRUD_formSubmit {
	  select when web submit "#formAppCRUD"
		pre {
		  mapvalues = event:attrs();
		}
		{
		  notify("appCRUD", "Data Saved to PDS") with sticky = true;
		  CloudRain:hideSpinner();
		}
		always {
		  raise pds event new_map_available
			  with namespace = "appCRUD"
				and  mapvalues = mapvalues
				and  _api = "sky";
		}
	}

  // ------------------------------------------------------------------------
  // Beyond here there be dragons :)
  // ------------------------------------------------------------------------
}
