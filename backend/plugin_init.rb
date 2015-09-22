Permission.define("update_onbase_record",
                  "The ability to create and update onbase records",
                  :level => "global")

Permission.define("delete_onbase_record",
                  "The ability to delete onbase records",
                  :level => "global")


require_relative "../lib/document_keyword_definitions"

ArchivesSpaceService.settings.scheduler.every('10s') do
  $stderr.puts("RUNNING JOB")
  OnbaseKeywordJob.process_jobs
end

