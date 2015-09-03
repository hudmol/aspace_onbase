require 'db/migrations/utils'

Sequel.migration do

  up do
    create_table(:onbase_document) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false
      Integer :json_schema_version, :null => false

      String :onbase_id, :null => false
      String :name, :null => false
      TextField :keywords

      apply_mtime_columns
    end

    alter_table(:onbase_document) do
      add_unique_constraint(:onbase_id, :name => "onbase_id_uniq")
    end

    create_table(:onbase_document_rlshp) do
      primary_key :id
      Integer :onbase_document_id
      Integer :accession_id
      Integer :aspace_relationship_position

      apply_mtime_columns(false)
    end

    alter_table(:onbase_document_rlshp) do
      add_foreign_key([:onbase_document_id], :onbase_document, :key => :id)
      add_foreign_key([:accession_id], :accession, :key => :id)
    end


  end

  down do
  end

end
