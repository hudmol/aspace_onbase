Permission.define("update_onbase_record",
                  "The ability to create and update onbase records",
                  :level => "global")

Permission.define("delete_onbase_record",
                  "The ability to delete onbase records",
                  :level => "global")


require_relative "../lib/document_keyword_definitions"
require_relative "../lib/file_buffer"

# Hit these early just to make sure they're set
settings = [:onbase_robi_url, :onbase_robi_username, :onbase_robi_password]
begin
  settings.each do |setting|
    AppConfig[setting]
  end
rescue
  msg = "You need to set the following config.rb settings: #{settings.inspect}"
  Log.error(msg)
  raise msg
end


ArchivesSpaceService.settings.scheduler.every '10s', :allow_overlapping => false do
  OnbaseKeywordJob.process_jobs
end


ArchivesSpaceService.settings.scheduler.every '10s', :allow_overlapping => false do
  OnbaseDocument.delete_unlinked_documents
end

