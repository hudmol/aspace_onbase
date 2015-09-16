module OnbaseDocuments

  def self.included(base)
    base.include(Relationships)
    base.extend(ClassMethods)

    base.define_relationship(:name => :onbase_document,
                             :json_property => 'onbase_documents',
                             :contains_references_to_types => proc {[OnbaseDocument]})
  end


  module ClassMethods

    def create_from_json(json, opts = {})
      obj = super

      if !Array(json.onbase_documents).empty?
        generator = DocumentKeywordsGenerator.new
        created_record = URIResolver.resolve_references(self.to_jsonmodel(obj), generator.get_resolved_types, {})

        Array(json.onbase_documents).each do |onbase_ref|
          ref = JSONModel.parse_reference(onbase_ref['ref'])

          next unless ref[:type] == 'onbase_document'
          onbase_document = OnbaseDocument.to_jsonmodel(ref[:id])

          keywords = generator.keywords_for(created_record, onbase_document)

          # magic!
          # ...
        end
      end

      obj
    end
  end

end
