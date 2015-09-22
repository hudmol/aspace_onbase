class OnbaseKeywordJob < Sequel::Model(:onbase_keyword_job)

  JOB_RETRY_TIME = 120

  def self.create(onbase_document, keywords, user)
    super(:onbase_id => onbase_document.id,
          :keywords => keywords.to_json,
          :status => "new",
          :user => user)
  end

  def self.process_jobs
    work_list = OnbaseKeywordJob.filter(:status => "new")

    work_list.each do |job|
      update_count = DB.open do
        OnbaseKeywordJob.filter(:status => "new", :id => job.id).update(:status => "running",
                                                                        :system_mtime => Time.now)
      end

      if update_count == 0
        # Someone else got in before we did
        next
      end

      job.upload_keywords
    end

    find_unfinished_jobs
  end


  def upload_keywords
    # HTTP
    client = OnbaseClient.new(:user => job.user)

    client.add_to_keywords(job.id, ASUtils.json_parse(job.keywords))
  end


  private

  def self.find_unfinished_jobs
    # mark any job older than N minutes as new so it gets retried
    DB.open do
      OnbaseKeywordJob.filter(:status => "pending").
        where { system_mtime < (Time.now - JOB_RETRY_TIME) }.
        update(:status => "new")
    end
  end

end
