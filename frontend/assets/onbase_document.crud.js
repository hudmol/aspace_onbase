function OnBaseRecordForm($container) {
  this.$container = $container;

  this.setup();
};

OnBaseRecordForm.prototype.setup = function() {
  this.$container.on("click", "#importOnBaseRecord", function(event) {
    event.preventDefault();

    alert("TODO: Make this AJAX POST the document and use resulting JSON to populate the form below")
  });
};
