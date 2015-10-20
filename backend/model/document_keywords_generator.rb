require 'date'

class DocumentKeywordsGenerator

  Keyword = Struct.new(:label, :keyword)

  def self.just_id(uri)
    Integer(JSONModel.parse_reference(uri)[:id])
  end

  def self.format_event_date(event_subrecord)
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


  def self.format_accession_date(accession_subrecord)
    accession_subrecord['accession_date']
  end


  def self.format_identifier(record)
    record['ref_id'] ||
      record['component_id'] ||
      (record['id_0'] && Identifiers.format((0...4).map {|i| record["id_#{i}"]})) ||
      record['uri']
  end



  GENERATORS = {
    :accession_system_id => proc {|record| Keyword.new(:accession_id_keyword, DocumentKeywordsGenerator.just_id(record['uri']))},
    :agent_name => proc {|record| Keyword.new(:agent_name_keyword, Array(record['linked_agents']).map {|agent| agent['_resolved']['title']}.join("; "))},
    :event_processing_plan_date => proc {|record| Keyword.new(:event_processing_plan_date_keyword, DocumentKeywordsGenerator.format_event_date(record)) },
    :accession_date => proc {|record| Keyword.new(:accession_date_keyword, DocumentKeywordsGenerator.format_accession_date(record)) },
    :event_system_id => proc {|record| Keyword.new(:event_id_keyword, DocumentKeywordsGenerator.just_id(record['uri']))},

    :linked_record_system_id => proc {|record|
      Array(record['linked_records']).map {|linked|
        parsed = JSONModel.parse_reference(linked['ref'])

        label = case parsed[:type]
                when 'accession'
                  :accession_id_keyword
                when 'resource'
                  :resource_id_keyword
                when 'archival_object'
                  :object_id_keyword
                end

        if label
          Keyword.new(label, parsed[:id])
        end
      }.compact
    },

    :agent_system_id => proc {|record|
      linked_agent = Array(record['linked_agents'])[0]
      if linked_agent
        Keyword.new(:agent_id_keyword, DocumentKeywordsGenerator.just_id(linked_agent['ref']))
      end
    },

    :record_identifier => proc {|record|
      Array(record['linked_records']).map {|linked|
        label = case linked['_resolved']['jsonmodel_type']
            when 'resource'
              :resource_identifier_keyword
            when 'accession'
              :accession_identifier_keyword
        end

        if label
          Keyword.new(label, DocumentKeywordsGenerator.format_identifier(linked['_resolved']))
        end
      }.compact
    },

    :example_alpha_250_keyword => proc {|record| Keyword.new(:example_alpha_250_keyword, DocumentKeywordsGenerator.just_id(record['uri']))},
  }


  def generator_for(code)
    GENERATORS.fetch(code)
  end


  def get_resolved_types
    ["linked_agents", "linked_records"]
  end


  def keywords_for(containing_jsonmodel, onbase_document)
    definitions = DocumentKeywordDefinitions.new

    fields_to_generate = definitions.definitions_for_document_type(onbase_document['document_type']).
                         select {|field| field[:type] == "generated"}

    keywords = {}

    fields_to_generate.each {|field|
      ASUtils.wrap(generator_for(field[:generator]).call(containing_jsonmodel)).each do |keyword|
        keywords[keyword.label] = keyword.keyword
      end
    }

    keywords
  end

end
