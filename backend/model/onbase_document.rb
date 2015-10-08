class OnbaseDocument < Sequel::Model(:onbase_document)
  include ASModel
  include Relationships

  corresponds_to JSONModel(:onbase_document)

  set_model_scope :global

  def display_string
    "#{filename} - #{document_type} [#{onbase_id}] :: #{linked_record_display}"
  end

  def self.sequel_to_jsonmodel(objs, opts = {})
    jsons = super

    jsons.zip(objs).each do |json, obj|
      json['display_string'] = obj.display_string
    end

    jsons
  end


  # Delete any document that isn't connected to an ArchivesSpace record
  def self.delete_unlinked_documents
    # FIXME: Fire the delete.  And delete from onbase?
    p OnbaseDocument.left_outer_join(OnbaseDocument.find_relationship(:onbase_document),
                                     :onbase_document_id => :id).
       filter(:onbase_document_id => nil).all
  end


  private

  def linked_record
    @linked_record ||= related_records(:onbase_document)[0]
  end

  def linked_record_display
    if linked_record
      if linked_record.respond_to?(:display_string)
        linked_record.display_string
      else
        "#{linked_record.class} #{linked_record.id}"
      end
    else
      "unlinked"
    end
  end


end
