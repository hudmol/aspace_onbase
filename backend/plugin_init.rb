Permission.define("update_onbase_record",
                  "The ability to create and update onbase records",
                  :level => "global")

Permission.define("delete_onbase_record",
                  "The ability to delete onbase records",
                  :level => "global")


require_relative "../lib/document_keyword_definitions"
require_relative "../lib/file_buffer"

# Hit these early just to make sure they're set
settings = [:onbase_robi_url, :onbase_robi_username, :onbase_robi_password,
            :onbase_keyword_job_interval_seconds,
            :onbase_delete_unlinked_documents_cron,
            :onbase_delete_obsolete_documents_cron]
begin
  settings.each do |setting|
    AppConfig[setting]
  end
rescue
  msg = "You need to set the following config.rb settings: #{settings.inspect}"
  Log.error(msg)
  raise msg
end


ArchivesSpaceService.settings.scheduler.every("#{AppConfig[:onbase_keyword_job_interval_seconds]}s", :allow_overlapping => false) do
  OnbaseKeywordJob.process_jobs
end


ArchivesSpaceService.settings.scheduler.cron(AppConfig[:onbase_delete_unlinked_documents_cron], :allow_overlapping => false) do
  Repository.each do |repo|
    RequestContext.open(:current_username => "admin",
                        :repo_id => repo.id) do
      OnbaseDocument.delete_unlinked_documents
    end
  end
end

ArchivesSpaceService.settings.scheduler.cron(AppConfig[:onbase_delete_obsolete_documents_cron], :allow_overlapping => false) do
  Repository.each do |repo|
    RequestContext.open(:current_username => "admin",
                        :repo_id => repo.id) do
      OnbaseDocument.delete_obsolete_documents
    end
  end
end
