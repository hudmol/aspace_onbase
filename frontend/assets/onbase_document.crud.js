function OnBaseRecordForm($container, onFormUpload) {
  this.$container = $container;
  this.$form = $container.closest("form");

  this.onFormUpload = onFormUpload;

  this.keywordsFormURL = $container.data("keywordsFormUrl");

  this.$progress = this.$container.find("#importOnBaseRecordProgress").hide();
  this.$progressBar = $(".progress-bar", this.$progress)

  this.setupForm();
};

OnBaseRecordForm.prototype.setupForm = function() {
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

      self.onFormUpload(json);
    },
    error: function(xhr) {
      alert("error");
    }
  });

  self.$form.find("#onbase_document_name_").on("change", function() {
    self.$container.find("#onBaseKeywords").load(self.keywordsFormURL, {doctype: $(this).val()});
  });
};


function OnBaseRecordLinker($container) {
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
    var $display = $("<dl>");
    $display.append($("<dt>").html("URI"));
    $display.append($("<dd>").html(json.uri));
    $display.append($("<dt>").html("Name"));
    $display.append($("<dd>").html(json.display_string));
    $display.append($("<dt>").html("JSON"));
    $display.append($("<dd>").html(JSON.stringify(json)));

    self.$container.find(".form-group").html($display);

    self.$container.find(":input.onbasedocument-ref").val(json.uri);

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
    new OnBaseRecordLinker(subform.find(".onbase-document-container"));
  }
});