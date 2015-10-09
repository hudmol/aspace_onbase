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
    client = OnbaseClient.new(:user => "ArchivesSpaceBackgroundTask")

    unlinked_ttl = if AppConfig.has_key?(:unlinked_onbase_document_ttl_seconds)
                     Integer(AppConfig[:unlinked_onbase_document_ttl_seconds])
                   else
                     24 * 60 * 60
                   end

    kill_time = Time.at(Time.now.to_i - unlinked_ttl)

    OnbaseDocument.left_outer_join(OnbaseDocument.find_relationship(:onbase_document),
                                   :onbase_document_id => :id).
      filter(:onbase_document_id => nil).
      select(:onbase_document__id, :onbase_document__onbase_id).
      where { Sequel.qualify(:onbase_document, :system_mtime) <= kill_time }.each do |row|

      puts "Checking row: #{row.inspect}"
      if client.delete(row[:onbase_id])
        puts "Deleting: #{OnbaseDocument[row[:id]]}"
      else
        puts "ALL OK"
      end
    end
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
