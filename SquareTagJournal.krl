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

    key aws {
      "AWSAccessKey": "0GEYA8DTVCB3XHM819R2",
      "AWSSecretKey": "I4TrjKcflLnchhsEzjlNju/s9EHiqdOScbyqGgn+"
    }
    use module a41x174 alias AWSS3
      with AWSKeys = keys:aws()
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

    S3Bucket = "k-mycloud";

    get_journal_entries = function(){

      myEntries = ent:entries.reverse();

      entriesListMade = myEntries.map(
        function(entry) {

          timeISO   = entry{"time"};
          time      = time:strftime(timeISO, "%c");
          entryText = entry{"entry"};
          thumbnail = entry{"thumbnail"};
          image = entry{"image"};
          imageHTML = <<
					  <a href="#{image}" class="fancybox" rel="JournalGallery" data-fancybox-type="image">
              <img src="#{thumbnail}" />
            </a>
          >>;
          imageLink = (image && image neq "none") => imageHTML | "None";

          thisEntry = <<
            <tr>
              <td>#{time}</td>
              <td>#{entryText}</td>
              <td>#{imageLink}</td>
            </tr>
          >>;

          thisEntry
        }
      ).join(" ");

      entriesListEmpty = <<
        <tr>
          <td>You have no journal entries</td>
          <td></td>
          <td></td>
        </tr>
      >>;

      entriesList = (myEntries.length() > 0) =>
        entriesListMade | 
        entriesListEmpty;

      entriesGallery = <<
        <h3>Journal Entries</h3>
        <table class="table table-striped">
          <thead>
            <tr>
              <th>Time</th>
              <th>Entry</th>
              <th>Image</th>
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
              <h3>Add Journal Entry</h3>
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
            <div class="control-group">
              <label class="control-label" for="imageFileInput">Image (Optional)</label>
              <div class="controls">
                <input type="file" class="input-xlarge" id="imageFileInput" /><br />
                <img id="thumbnailPreview" />
                <input name="thumbnailSource" id="thumbnailSource" type="hidden"/>
                <input name="imageSource" id="imageSource" type="hidden"/>
              </div>
            </div>
            <div class="form-actions">
              <button type="submit" class="btn btn-primary">Save Entry</button>
            </div>
          </fieldset>
        </form>

        <div class="wrapper squareTag" id="journalEntries">
          #{journalEntries}
        </div>
      >>;

      entries = ent:entries;
    }
    {
      SquareTag:inject_styling();
      CloudRain:createAppPanel(thisRID, "Journal", {});
      CloudRain:loadAppPanel(thisRID, html);
      CloudRain:skyWatchPost("formAddJournalEntry", meta:eci());
      emit <<
        $K("#imageFileInput").change(function(e) {
          var file = e.target.files[0];
          KOBJ.canvasResize(file, {
            width: 120,
            height: 0,
            crop: false,
            quality: 80,
            callback: function(data, width, height) {
              $K("#thumbnailPreview").attr("src", data);
              $K("#thumbnailSource").val(data);
            }
          });
          KOBJ.canvasResize(file, {
            width: 1200,
            height: 1200,
            crop: false,
            quality: 80,
            callback: function(data, width, height) {
              $K("#imageSource").val(data);
            }
          });
        }); 
        $K('.fancybox').fancybox();
      >>;
    }
  }
  // ------------------------------------------------------------------------
  rule saveBoard {
    select when web submit "#formAddJournalEntry.post"
    pre {
      time = time:now({tz:'America/Denver'});

      entryText = event:attr("entryText");
      thumbnailSource = event:attr("thumbnailSource");
      imageSource = event:attr("imageSource");

      imageType = (thumbnailSource) => AWSS3:getType(thumbnailSource) | "none";

      guid = random:uuid();

      thumbName   = "#{thisRID}/#{thisECI}-#{guid}-thumbnail.img";
      thumbURL = (thumbnailSource) => "https://s3.amazonaws.com/#{S3Bucket}/#{thumbName}" | "none";
      thumbValue  = (thumbnailSource) => this2that:base642string(AWSS3:getValue(thumbnailSource)) | "none";


      imageName   = "#{thisRID}/#{thisECI}-#{guid}.img";
      imageURL = (imageSource) => "https://s3.amazonaws.com/#{S3Bucket}/#{imageName}" | "none";
      imageValue  = (imageSource) => this2that:base642string(AWSS3:getValue(imageSource)) | "none";

      entry  = {
        "thumbnail": thumbURL,
        "image": imageURL,
        "entry": entryText,
        "time": time
      };

      entries = (ent:entries || []).append(entry);
    }
    if(thumbnailSource && imageSource) then {
      AWSS3:upload(S3Bucket, thumbName, thumbValue)
        with object_type = imageType;
      AWSS3:upload(S3Bucket, imageName, imageValue)
        with object_type = imageType;
      emit <<
        console.log("NEW ENTRY");
      >>;
    }
    always {
      set ent:entries entries if
        ((imageSource && thumbnailSource) || entryText);
    }
  }

  rule showEntries {
    select when web submit "#formAddJournalEntry$"
    pre {
      journalEntries = get_journal_entries();
    }
    {
      emit <<
        $K("#journalEntries").html(journalEntries);
        $K("#formAddJournalEntry")[0].reset();
        $K('.fancybox').fancybox();
      >>;
      CloudRain:hideSpinner();
    }
  }

  rule resetEntries {
    select when web submit "#formReset"
    {
      noop();
    }
    fired {
      clear ent:entries;
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
