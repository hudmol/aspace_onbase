class DocumentKeywordDefinitions

  DOCUMENT_TYPE_DEFINITIONS = {
    "SPCL-Agent Correspondence" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_id},
      ]},

    "SPCL-Deed" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_id},
        {:type => "generated", :code => :record_id},
      ]},

    "SPCL-Transfer Receipt" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_id},
        {:type => "generated", :code => :record_id},
      ]},

    "SPCL-Dealer Object Description" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_id},
        {:type => "generated", :code => :record_id},
      ]},

    "SPCL-Processing Plan" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :record_id},
        {:type => "generated", :code => :event_date},
        {:type => "generated", :code => :event_id},
      ]},

    "SPCL-Accession Snapshot" => {
      :supported_records => [:accession],
      :fields => [
        {:type => "generated", :code => :accession_id},
        {:type => "generated", :code => :current_date},
      ]},

    "SPCL-Preservation Photos" => {
      :supported_records => [:event],
      :fields => [
        {:type => "text", :code => :conservation_number},
        {:type => "generated", :code => :event_id},
        {:type => "generated", :code => :record_id},
      ]},

    "SPCL-Preservation Documentation" => {
      :supported_records => [:event],
      :fields => [
        {:type => "text", :code => :conservation_number},
        {:type => "generated", :code => :event_id},
        {:type => "generated", :code => :record_id},
      ]},

    "SPCL-Missing Items record" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :event_id},
        {:type => "generated", :code => :record_id},
      ]},

    "SPCL-Oral History Release Forms" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :agent_name},
        {:type => "generated", :code => :event_id},
        {:type => "generated", :code => :record_id},
      ]},

    "SPCL-Deaccession record" => {
      :supported_records => [:event],
      :fields => [
        {:type => "generated", :code => :event_id},
        {:type => "generated", :code => :record_id},
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
    DOCUMENT_TYPE_DEFINITIONS.find {|definition| definition[:supported_records].include?(record_type)}
  end

  def definitions_for_document_type(document_type)
    DOCUMENT_TYPE_DEFINITIONS.fetch(document_type)[:fields]
  end

end
