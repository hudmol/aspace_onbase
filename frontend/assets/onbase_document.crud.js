function OnBaseRecordForm($container, onFormUpload) {
  this.$container = $container;
  this.$form = $container.closest("form");

  this.onFormUpload = onFormUpload;

  this.$progress = this.$container.find("#importOnBaseRecordProgress").hide();
  this.$progressBar = $(".progress-bar", this.$progress)

  this.setup();
};

OnBaseRecordForm.prototype.setup = function() {
  var self = this;

  self.$form.ajaxForm({
    type: "POST",

    beforeSubmit: function(arr, $form, options) {
      self.$progress.show();
    },
    uploadProgress: function(event, position, total, percentComplete) {
      var percentVal = percentComplete + '%';
      self.$progressBar.width(percentVal);
    },
    success: function(json, status, xhr) {
      var percentVal = '100%';
      self.$progressBar.width(percentVal)
      self.$progress.removeClass("active").removeClass("progress-striped");
      self.$progressBar.addClass("progress-bar-success");

      $("#importOnBaseRecordResult", self.$container).show().text(JSON.stringify(json));

      self.onFormUpload(json);
    },
    error: function(xhr) {
      alert("error");
    }
  });


  self.$container.on("click", "#importOnBaseRecord", function(event) {
    event.preventDefault();

    self.$form.ajaxSubmit({
      type: "POST",

      beforeSubmit: function(arr, $form, options) {
        $("#importOnBaseRecord").remove();
        self.$progress.show();
      },
      uploadProgress: function(event, position, total, percentComplete) {
        var percentVal = percentComplete + '%';
        self.$progressBar.width(percentVal);
      },
      success: function(json, status, xhr) {
        var percentVal = '100%';
        self.$progressBar.width(percentVal)
        self.$progress.removeClass("active").removeClass("progress-striped");
        self.$progressBar.addClass("progress-bar-success");

        $("#importOnBaseRecordResult", self.$container).show().text(JSON.stringify(json));
        //self.$outerContainer.find(":submit").prop("disabled", false);
      },
      error: function(xhr) {
        alert("error");
      }
    });
  });
};


function OnBaseRecordLinker($linker, $container) {
  this.$linker = $linker;
  this.$container = $container;

  this.setupUploadAction();
};

OnBaseRecordLinker.prototype.setupUploadAction = function() {
  var self = this;

  self.$container.on("click", ".upload-onbase-document-btn", function() {
    self.openUploadModal($(this).data("target"));
  });
};

OnBaseRecordLinker.prototype.openUploadModal = function(formUrl) {
  var self = this;

  var $modal = AS.openCustomModal("uploadOnBaseDocumentModal", "Upload an OnBase Document", AS.renderTemplate("aspace_onbase_upload_template"), 'large', {}, this);

  function setupUploadForm(html) {
    $modal.find(".upload-onbase-document-container").html(html);

    $modal.on("click", "#uploadAndLinkOnBaseDocumentButton", function() {
      $modal.find("form").submit();
    });

    new OnBaseRecordForm($modal.find("#onbaseDocumentFormFields"), $.proxy(onFormUpload, self));
  };

  function onFormUpload(json) {
    self.$linker.tokenInput("add", {
      id: "TODO",
      name: "TODO",
      json: json
    });

    self.$linker.triggerHandler("change");
    $modal.modal("hide");
  };

  $.get(formUrl, function(html) {
    setupUploadForm(html);
  });

  $modal.scrollTo(".alert");
  $modal.trigger("resize");
};

$(document).bind("subrecordcreated.aspace", function(event, object_name, subform) {
  if (object_name === "onbase_document") {
    new OnBaseRecordLinker(subform.find(".linker"), subform);
  }
});