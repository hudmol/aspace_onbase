require 'date'

# FIXME: Do a sanity check on startup to make sure generators aren't missing
class DocumentKeywordsGenerator

  Keyword = Struct.new(:label, :keyword)


  GENERATORS = {
    :accession_id => proc {|record| Keyword.new("Accession ID", record.uri)},
    :agent_name => proc {|record| Keyword.new("Agent Name", Array(record['linked_agents']).map {|agent| agent['_resolved']['title']}.join("; "))},
    :current_date => proc {|record| Keyword.new("Date", Date.today.iso8601) },
    :event_date => proc {|record| Keyword.new("Date", format_date(record)) },
    :event_id => proc {|record| Keyword.new("Event ID", record['uri'])},
    :record_id => proc {|record| Keyword.new("Record ID", record['linked_records'].map {|linked| linked['ref']}.join("; ")) },
    :agent_id => proc {|record| Keyword.new("Agent ID", Array(record['linked_agents']).map {|agent| agent['ref']}.join("; ")) },
    :record_identifier => proc {|record| Keyword.new("Record Identifier", record['linked_records'].map {|linked| format_identifier(linked['_resolved'])}.join("; ")) },
  }


  def generator_for(code)
    GENERATORS.fetch(code)
  end


  def get_resolved_types
    ["linked_agents"]
  end


  def keywords_for(containing_jsonmodel, onbase_document)
    definitions = DocumentKeywordDefinitions.new

    # onbase_document
    $stderr.puts("\n*** DEBUG #{(Time.now.to_f * 1000).to_i} [document_keywords_generator.rb:28 43c229]: " + {'onbase_document' => onbase_document}.inspect + "\n")

    # containing_jsonmodel
    $stderr.puts("\n*** DEBUG #{(Time.now.to_f * 1000).to_i} [document_keywords_generator.rb:36 6e43d9]: " + {'containing_jsonmodel' => containing_jsonmodel}.inspect + "\n")

    fields_to_generate = definitions.definitions_for_document_type(onbase_document['document_type']).
                         select {|field| field[:type] == "generated"}

    keywords = fields_to_generate.map {|field|
      generator_for(field[:code]).call(containing_jsonmodel)
    }

    # keywords
    $stderr.puts("\n*** DEBUG #{(Time.now.to_f * 1000).to_i} [document_keywords_generator.rb:153 ae9818]: " + {'keywords' => keywords}.inspect + "\n")

    keywords
  end


  private

  def format_date(event_subrecord)
    if event_subrecord['timestamp']
      event_subrecord['timestamp']
    else
      date = event_subrecord['date']

      if date['begin'] || date['end']
        [date['begin'], date['end']].compact.join(" -- ")
      else
        date['expression']
      end
    end
  end

  def format_identifier(record)
    record['ref_id'] ||
      record['component_id'] ||
        record['id_0'] && Identifers.format((0...4).map {|i| record['_resolved']["id_#{i}"]})
          record['uri']
  end

end
