require 'db/migrations/utils'

Sequel.migration do

  up do
    create_table(:onbase_keyword_job) do
      primary_key :id

      String :onbase_id, :null => false
      String :status, :default => 'new'
      String :user, :null => false
      DateTime :system_mtime, :null => false, :index => true
      TextField :keywords
    end

    alter_table(:onbase_keyword_job) do
      add_unique_constraint([:onbase_id], :name => "onbase_job_uniq_id")
    end
  end

  down do
  end

end
