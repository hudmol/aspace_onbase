class DocumentKeywordDefinitions

  DOCUMENT_TYPE_DEFINITIONS = {
    "SPCL-Agent Correspondence" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_system_id},
        {:type => "generated", :code => :agent_system_id},
      ]},

    "SPCL-Deed" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_system_id},
        {:type => "generated", :code => :linked_record_system_id},
        {:type => "generated", :code => :agent_system_id},
        {:type => "generated", :code => :record_identifier},
      ]},

    "SPCL-Transfer Receipt" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_system_id},
        {:type => "generated", :code => :linked_record_system_id},
        {:type => "generated", :code => :agent_system_id},
        {:type => "generated", :code => :record_identifier},
      ]},

    "SPCL-Dealer Object Description" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_system_id},
        {:type => "generated", :code => :linked_record_system_id},
        {:type => "generated", :code => :agent_system_id},
        {:type => "generated", :code => :record_identifier},
      ]},

    "SPCL-Processing Plan" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :linked_record_system_id},
        {:type => "generated", :code => :event_processing_plan_date},
        {:type => "generated", :code => :event_system_id},
        {:type => "generated", :code => :record_identifier},
        {:type => "text", :code => :catalog_location_keyword},
      ]},

    "SPCL-Accession Snapshot" => {
      :supported_records => [:accession],
      :fields => [
        {:type => "generated", :code => :accession_system_id},
        {:type => "generated", :code => :accession_date},
        {:type => "generated", :code => :record_identifier},
      ]},

    "SPCL-Preservation Photos" => {
      :supported_records => [:event],
      :fields => [
        {:type => "text", :code => :conservation_number_keyword},
        {:type => "generated", :code => :event_system_id},
        {:type => "generated", :code => :linked_record_system_id},
        {:type => "generated", :code => :record_identifier},
        {:type => "text", :code => :catalog_location_keyword},
      ]},

    "SPCL-Preservation Documentation" => {
      :supported_records => [:event],
      :fields => [
        {:type => "text", :code => :conservation_number_keyword},
        {:type => "generated", :code => :event_system_id},
        {:type => "generated", :code => :linked_record_system_id},
        {:type => "generated", :code => :record_identifier},
        {:type => "text", :code => :catalog_location_keyword},
      ]},

    "SPCL-Missing Items record" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :event_system_id},
        {:type => "generated", :code => :linked_record_system_id},
        {:type => "generated", :code => :record_identifier},
      ]},

    "SPCL-Oral History Release Forms" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_system_id},
        {:type => "generated", :code => :linked_record_system_id},
        {:type => "generated", :code => :record_identifier},
      ]},

    "SPCL-Deaccession record" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :event_system_id},
        {:type => "generated", :code => :linked_record_system_id},
        {:type => "generated", :code => :record_identifier},
        {:type => "text", :code => :catalog_location_keyword},
      ]},

    "SPCL-Patron Registration Forms" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_system_id},
      ]},

    "SPCL-Permission to Publish" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_system_id},
      ]},

    "SPCL-Loan Agreement" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_system_id},
      ]},

    "SPCL-Facilities Report" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_system_id},
      ]},

    "SPCL-Insurance Valuations" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_system_id},
      ]},

    "SPCL - Example Document Type" => {
      :supported_records => [:event, :accession],
      :fields => [
        {:type => "text", :code => :example_alpha_20_keyword},
        {:type => "generated", :code => :example_alpha_250_keyword}
      ]
    }
  }

  def document_types_for_record(record_type)
    DOCUMENT_TYPE_DEFINITIONS.select {|doctype, definition | definition[:supported_records].include?(record_type)}
  end

  def definitions_for_document_type(document_type)
    DOCUMENT_TYPE_DEFINITIONS.fetch(document_type)[:fields]
  end

end
