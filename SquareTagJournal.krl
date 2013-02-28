ruleset a41x193 {
  meta {
    name "Journal"
    description <<
      Journal

      Copyright 2012 Kynetx, All Rights Reserved
    >>
    author "Jessie A. Morris"
    // Uncomment this line to require Marketplace purchase to use this app.
    // authz require user
    logging off

		use module a169x701 alias CloudRain
    use module a169x676 alias pds
    use module a41x196 alias SquareTag
  }

  dispatch {
    // Some example dispatch domains
    // domain "example.com"
    // domain "other.example.com"
  }

  global {
		thisRID = meta:rid();
		thisECI = meta:eci();
		SquareTagRID = "a41x178";

    get_journal_entries = function(){

      myEntries = ent:entries;

      entriesListMade = myEntries.map(
        function(entry) {

          time = entry{"time"};
          entryText = entry{"entry"};

          thisEntry = <<
            <tr>
              <td>#{time}</td>
              <td>#{entryText}</td>
            </tr>
          >>;

          thisEntry
        }
      ).join(" ");

      entriesListEmpty = <<
        <tr>
          <td>You have no journal entries</td>
          <td></td>
        </tr>
      >>;

      entriesList = (myEntries.length() > 0) =>
        entriesListMade | 
        entriesListEmpty;

      entriesGallery = <<
        <legend>Journal Entries</legend>
        <table class="table table-striped">
          <thead>
            <tr>
              <th>Time</th>
              <th>Entry</th>
            </tr>
          </thead>
          <tbody>
            #{entriesList}
          </tbody>
        </table>
      >>;

      // return the gallery
      entriesGallery
    };

  }

  rule ifOwner {
    select when explicit isOwner
    or          web cloudAppSelected
    pre {
      defaultAppHtml = SquareTag:get_default_app_html(thisRID);

      profile = pds:get_all_me();
      myProfileName = profile{"myProfileName"};
      myProfilePhoto = profile{"myProfilePhoto"};

      journalEntries = get_journal_entries();

      html = <<
        #{defaultAppHtml}
        <form id="formAddJournalEntry" class="form-horizontal form-mycloud">
          <fieldset>
            <div class="wrapper squareTag">
              <legend>Add Journal Entry</legend>
            </div>
            <div class="control-group">
              <div class="controls">
                <div class="thumbnail-wrapper" style="width: 100px;">
                  <div class="thumbnail mycloud-thumbnail">
                    <img src="#{myProfilePhoto}" alt="#{myProfileName}">
                    <h5 class="cloudUI-center">#{myProfileName}</h5>
                  </div>  <!-- .thumbnail -->
                </div>
              </div>
            </div>
            <div class="control-group">
              <label class="control-label" for="entryText">Entry</label>
              <div class="controls">
                <textarea class="input-xlarge" name="entryText" title="Your journal entry" placeholder="Your journal entry"></textarea>
              </div>
            </div>
            <div class="form-actions" style="margin-bottom: 50px;">
              <button type="submit" class="btn btn-primary">Save Entry</button>
            </div>
          </fieldset>
        </form>

        <div class="wrapper squareTag">
          #{journalEntries}
        </div>
      >>;
    }
    {
      SquareTag:inject_styling();
      CloudRain:createAppPanel(thisRID, "Journal", {});
      CloudRain:loadAppPanel(thisRID, html);
      CloudRain:skyWatchSubmit("#formAddJournalEntry", meta:eci());
    }
  }

  rule saveEntry {
    select when web submit "#formAddJournalEntry"
    pre {
      entryText = event:attr("entryText");

      timeNow = time:now({"tz": "America/Denver"});
      queid   = time:strftime(timeNow, "%c");

      entryData = {
        "entry": entryText,
        "time": queid
      };

      entries = (ent:entries || []).append(entryData);
    }
    {
      noop();
    }
    fired {
      set ent:entries entries;
    }
  }

  rule showEntries {
    select when web submit "#formAddJournalEntry"
    pre {
      journalEntries = get_journal_entries();
    }
    {
      replace_html("#journalEntries", journalEntries);
    }
  }

  rule makeDefault {
    select when web cloudAppAction action re/makeDefault/
    {
      replace_html("#makeDefaultSquareTagApp", "");
      CloudRain:hideSpinner();
    }
    fired {
      raise pds event new_settings_attribute
        with _api = "sky"
        and setRID = SquareTagRID
        and setAttr = "defaultOwnerApp"
        and setValue = thisRID;
    }
  }
}
