require 'date'

class DocumentKeywordsGenerator
    
  Keyword = Struct.new(:label, :keyword)

  def self.just_id(uri)
    Integer(JSONModel.parse_reference(uri)[:id])
  end

  def self.format_event_date(event_subrecord)
    if event_subrecord['timestamp']
      event_subrecord['timestamp']
    elsif event_subrecord['date']
      date = event_subrecord['date']

      if date['begin'] || date['end']
        [date['begin'], date['end']].compact.join(" -- ")
      else
        date['expression']
      end
    else
      date = DateTime.now
    end
  end


  def self.format_accession_date(accession_subrecord)
    accession_subrecord['accession_date'] ? accession_subrecord['accession_date'] : DateTime.now
  end


  def self.format_identifier(record)
    record['ref_id'] ||
      record['component_id'] ||
      (record['id_0'] && Identifiers.format((0...4).map {|i| record["id_#{i}"]})) ||
      record['uri']
  end

  GENERATORS = {
    :agent_name => proc {|record|
      Array(record['linked_agents']).map {|agent|
        if agent['_resolved']['title']
          Keyword.new(:agent_name_keyword, agent['_resolved']['title'])
        end
      }
    },
    :event_processing_plan_date => proc {|record| Keyword.new(:event_processing_plan_date_keyword, DocumentKeywordsGenerator.format_event_date(record)) },
    :accession_date => proc {|record| Keyword.new(:accession_date_keyword, DocumentKeywordsGenerator.format_accession_date(record)) },
    :parent_system_id => proc {|record|
      Array(record['jsonmodel_type']).map {|type|
        type_label = case type
                when 'event'
                  :event_id_keyword
                when 'resource'
                  :resource_id_keyword
                when 'accession'
                  :accession_id_keyword
                when 'archival_object'
                  :object_id_keyword
                end
        if type_label
          Keyword.new(type_label, DocumentKeywordsGenerator.just_id(record['uri']))
        end        
      }.compact
    },

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
      Array(record['linked_agents']).map {|agent|
      if agent['ref']
        Keyword.new(:agent_id_keyword, DocumentKeywordsGenerator.just_id(agent['ref']))
      end
      }.compact
    },

    :record_identifier => proc {|record|
      if record['jsonmodel_type'] == ('event' || 'archival_object')
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
      # this isn't the best solution as it only returns the uri for these types
      # better would be to find a nice way to grab the identifiers id_0, etc for the record
      else
          label = case record['jsonmodel_type']
              when 'resource'
                :resource_identifier_keyword
              when 'accession'
                :accession_identifier_keyword
          end
          
          if label
            Keyword.new(label, DocumentKeywordsGenerator.format_identifier(record))
          end
      end
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
                         
    non_generated_fields = definitions.definitions_for_document_type(onbase_document['document_type']).
                        select{|field| field[:type] != "generated"}

    keywords = {}
    # allow duplicate keys in the hash
    keywords.compare_by_identity
    
    fields_to_generate.each {|field|
      ASUtils.wrap(generator_for(field[:generator]).call(containing_jsonmodel)).each do |keyword|
        keywords[keyword.label.to_s] = keyword.keyword
      end
    }
    # find the keywords that will only be set on initial save since we will need to keep these when we fetch back from OnBase
    non_generated_fields.each do |keyword|
      keywords[:not_generated.to_s] = KeywordNameMapper.translate(keyword[:keyword])
    end

    keywords
  end

end
