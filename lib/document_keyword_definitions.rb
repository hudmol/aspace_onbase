class DocumentKeywordDefinitions

  DOCUMENT_TYPE_DEFINITIONS = {
    "SPCL-Agent Correspondence" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_id},
        {:type => "generated", :code => :agent_id},
      ]},

    "SPCL-Deed" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_id},
        {:type => "generated", :code => :record_id},
        {:type => "generated", :code => :agent_id},
        {:type => "generated", :code => :record_identifier},
      ]},

    "SPCL-Transfer Receipt" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_id},
        {:type => "generated", :code => :record_id},
        {:type => "generated", :code => :agent_id},
        {:type => "generated", :code => :record_identifier},
      ]},

    "SPCL-Dealer Object Description" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_id},
        {:type => "generated", :code => :record_id},
        {:type => "generated", :code => :agent_id},
        {:type => "generated", :code => :record_identifier},
      ]},

    "SPCL-Processing Plan" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :record_id},
        {:type => "generated", :code => :event_date},
        {:type => "generated", :code => :event_id},
        {:type => "generated", :code => :record_identifier},
        {:type => "text", :code => :catalog_location},
      ]},

    "SPCL-Accession Snapshot" => {
      :supported_records => [:accession],
      :fields => [
        {:type => "generated", :code => :accession_id},
        {:type => "generated", :code => :current_date},
        {:type => "generated", :code => :record_identifier},
      ]},

    "SPCL-Preservation Photos" => {
      :supported_records => [:event],
      :fields => [
        {:type => "text", :code => :conservation_number},
        {:type => "generated", :code => :event_id},
        {:type => "generated", :code => :record_id},
        {:type => "generated", :code => :record_identifier},
        {:type => "text", :code => :catalog_location},
      ]},

    "SPCL-Preservation Documentation" => {
      :supported_records => [:event],
      :fields => [
        {:type => "text", :code => :conservation_number},
        {:type => "generated", :code => :event_id},
        {:type => "generated", :code => :record_id},
        {:type => "generated", :code => :record_identifier},
        {:type => "text", :code => :catalog_location},
      ]},

    "SPCL-Missing Items record" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :event_id},
        {:type => "generated", :code => :record_id},
        {:type => "generated", :code => :record_identifier},
      ]},

    "SPCL-Oral History Release Forms" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_id},
        {:type => "generated", :code => :record_id},
        {:type => "generated", :code => :record_identifier},
      ]},

    "SPCL-Deaccession record" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :event_id},
        {:type => "generated", :code => :record_id},
        {:type => "generated", :code => :record_identifier},
        {:type => "text", :code => :catalog_location},
      ]},

    "SPCL-Patron Registration Forms" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_id},
      ]},

    "SPCL-Permission to Publish" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_id},
      ]},

    "SPCL-Loan Agreement" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_id},
      ]},

    "SPCL-Facilities Report" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_id},
      ]},

    "SPCL-Insurance Valuations" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_id},
      ]},
  }

  def document_types_for_record(record_type)
    DOCUMENT_TYPE_DEFINITIONS.select {|doctype, definition | definition[:supported_records].include?(record_type)}
  end

  def definitions_for_document_type(document_type)
    DOCUMENT_TYPE_DEFINITIONS.fetch(document_type)[:fields]
  end

end
