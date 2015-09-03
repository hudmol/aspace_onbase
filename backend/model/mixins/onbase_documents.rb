module OnbaseDocuments

  def self.included(base)
    base.include(Relationships)

    base.define_relationship(:name => :onbase_document,
                             :json_property => 'onbase_documents',
                             :contains_references_to_types => proc {[OnbaseDocument]})
  end

end
