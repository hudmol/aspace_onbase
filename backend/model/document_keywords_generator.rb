require 'date'

# FIXME: Do a sanity check on startup to make sure generators aren't missing
class DocumentKeywordsGenerator

  Keyword = Struct.new(:label, :keyword)

  def self.just_id(uri)
    Integer(JSONModel.parse_reference(uri)[:id])
  end

  def self.format_date(event_subrecord)
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

  def self.format_identifier(record)
    record['ref_id'] ||
      record['component_id'] ||
      (record['id_0'] && Identifiers.format((0...4).map {|i| record["id_#{i}"]})) ||
      record['uri']
  end



  GENERATORS = {
    :accession_system_id => proc {|record| Keyword.new("Accession ID", DocumentKeywordsGenerator.just_id(record['uri']))},
    :agent_name => proc {|record| Keyword.new("Agent Name", Array(record['linked_agents']).map {|agent| agent['_resolved']['title']}.join("; "))},
    :current_date => proc {|record| Keyword.new("Date", Date.today.iso8601) },
    :event_date => proc {|record| Keyword.new("Date", DocumentKeywordsGenerator.format_date(record)) },
    :event_system_id => proc {|record| Keyword.new("Event ID", DocumentKeywordsGenerator.just_id(record['uri']))},

    :linked_record_system_id => proc {|record|
      Array(record['linked_records']).map {|linked|
        parsed = JSONModel.parse_reference(linked['ref'])

        label = case parsed[:type]
                when 'accession'
                  "Accession ID"
                when 'resource'
                  "Resource ID"
                when 'archival_object'
                  "Object ID"
                end

        if label
          Keyword.new(label, parsed[:id])
        end
      }.compact
    },

    # FIXME: what happens if there's more than one linked agent?
    :agent_system_id => proc {|record|
      linked_agent = Array(record['linked_agents'])[0]
      if linked_agent
        Keyword.new("Agent ID", DocumentKeywordsGenerator.just_id(linked_agent['ref']))
      end
    },

    :record_identifier => proc {|record|
      Array(record['linked_records']).map {|linked|
        label = case linked['_resolved']['jsonmodel_type']
            when 'resource'
              "Resource Identifier"
            when 'accession'
              "Accession Identifier"
        end

        if label
          Keyword.new(label, DocumentKeywordsGenerator.format_identifier(linked['_resolved']))
        end
      }.compact
    },

    "SPCL-ExampleAlpha250" => proc {|record|  Keyword.new("SPCL-ExampleAlpha250", DocumentKeywordsGenerator.just_id(record['uri']))},
  }


  def generator_for(code)
    GENERATORS.fetch(code)
  end


  def get_resolved_types
    ["linked_agents", "linked_records"]
  end


  def keywords_for(containing_jsonmodel, onbase_document)
    definitions = DocumentKeywordDefinitions.new

    # onbase_document
    $stderr.puts("\n*** DEBUG #{(Time.now.to_f * 1000).to_i} [document_keywords_generator.rb:28 43c229]: " + {'onbase_document' => onbase_document}.inspect + "\n")

    # containing_jsonmodel
    $stderr.puts("\n*** DEBUG #{(Time.now.to_f * 1000).to_i} [document_keywords_generator.rb:36 6e43d9]: " + {'containing_jsonmodel' => containing_jsonmodel}.inspect + "\n")

    fields_to_generate = definitions.definitions_for_document_type(onbase_document['document_type']).
                         select {|field| field[:type] == "generated"}

    keywords = {}

    fields_to_generate.each {|field|
      ASUtils.wrap(generator_for(field[:code]).call(containing_jsonmodel)).each do |keyword|
        keywords[keyword.label] = keyword.keyword
      end
    }

    # keywords
    $stderr.puts("\n*** DEBUG #{(Time.now.to_f * 1000).to_i} [document_keywords_generator.rb:153 ae9818]: " + {'keywords' => keywords}.inspect + "\n")

    keywords
  end

end
