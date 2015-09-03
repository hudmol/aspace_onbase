class OnbaseDocument < Sequel::Model(:onbase_document)
  include ASModel
  corresponds_to JSONModel(:onbase_document)

  set_model_scope :global

end
