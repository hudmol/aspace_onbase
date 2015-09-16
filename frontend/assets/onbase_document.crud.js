function OnBaseRecordForm($container, uploadAction) {
  this.$container = $container;
  this.$form = $container.closest("form");
  this.$outerContainer = $container.closest(".modal").length > 0 ? $container.closest(".modal") : this.$form;

  this.uploadAction = uploadAction;

  this.$progress = this.$container.find("#importOnBaseRecordProgress").hide();
  this.$progressBar = $(".progress-bar", this.$progress)

  this.setup();
};

OnBaseRecordForm.prototype.setup = function() {
  var self = this;

  if (self.$container.find("#importOnBaseRecord").length > 0) {
    // import required
    setTimeout(function() {
      self.$outerContainer.find(":submit:not(#importOnBaseRecord, .btn-cancel)").prop("disabled", true);
    });
  }


  self.$container.on("click", "#importOnBaseRecord", function(event) {
    event.preventDefault();

    self.$form.ajaxSubmit({
      type: "POST",
      url: self.uploadAction,

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
        self.$outerContainer.find(":submit").prop("disabled", false);
      },
      error: function(xhr) {
        alert("error");
      }
    });
  });
};
