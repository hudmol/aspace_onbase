require 'net/http'
require 'net/http/post/multipart'

class OnbaseClient

  def initialize(opts = {})
    @base_url = 'https://onbase-dev.dartmouth.edu/api/OWMROBIInstance/api/documents/'
    @username = ENV.fetch("ONBASE_USERNAME")
    @password = ENV.fetch("ONBASE_PASSWORD")

    @user = opts.fetch(:user)
  end


  def upload(file_stream, file_name, content_type, doc_type, keywords = {})
    req = Net::HTTP::Post::Multipart.new(url('', {"documentTypeName" => doc_type}),
                                         "file" => UploadIO.new(file_stream, content_type, file_name),
                                         "keywords" => format_keywords(keywords).to_json)

    req.basic_auth @username, @password

    res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
      http.request(req)
    end

#    puts IO.read(docStream)
    p "OnbaseClient.upload: #{doc_type}, #{format_keywords(keywords).to_json}"
    p res
    p res.body

    res.body
  end


  def get(suffix)
    Net::HTTP.start(@url.host, @url.port) do |http|
      req = Net::HTTP::Get.new(url(suffix))

      req.basic_auth @username, @password
      response = http.request(req)

      if response.status != 200
        raise "Failure in GET request from onbase: #{response.body}"
      end

      response
    end
  end


  def get_json(suffix)
    ASUtils.json_parse(get(suffix).body)
  end


  def put_json(suffix, json)
    Net::HTTP.start(@url.host, @url.port) do |http|
      req = Net::HTTP::Put.new(url(suffix))
      req['Content-type'] = 'text/json'
      req.body = json
      req.basic_auth @username, @password

      response = http.request(req)

      if response.status.to_s !~ /^2/
        raise "Failure in PUT request to onbase: #{response.body}"
      end

      response
    end
  end


  def add_to_keywords(onbase_id, keywords)
    onbase_keywords = get_keywords(onbase_id)

    merged = onbase_keywords.merge('keywords' => merge_keywords(onbase_keywords['keywords'], format_keywords(keywords)))
    put_keywords(job.onbase_id, merged)
  end


  def get_keywords(onbase_id)
    get_json("#{onbase_id}/keywords")
  end

  def put_keywords(onbase_id, keywords)
    put_json("#{onbase_id}/keywords", keywords.to_json)
  end


  private


  def url(suffix, params = {})
    s = "#{@base_url}/{suffix}".gsub(/\/+$/, '')
    uri = URI(s)
    uri.query = encode_www_form(params.merge('logUser' => @user))

    uri
  end


  def merge_keywords(*keywords)
    keywords.reduce {|k1, k2| k1 + k2}.reverse.uniq {|k| k['keywordTypeName']}
  end


  def format_keywords(keywords)
    keywords.map do |name, value|
      {
        "keywordTypeName" => name,
        "keywordValue" => value
      }
    end
  end

end
