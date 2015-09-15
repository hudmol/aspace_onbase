require 'net/http'
require 'net/http/post/multipart'

class OnbaseClient

  def initialize(opts = {})
    @url = URI.parse('https://onbase-dev.dartmouth.edu/api/OWMROBIInstance/api/documents/')
    @username = 'me'
    @password = 'reallyme'
  end


  def upload(file_stream, file_name, content_type, doc_type, log_user, keywords = "")

    url = @url
    url.query = URI.encode_www_form([["documentTypeName", doc_type],
                                     ["logUser", log_user]])

    req = Net::HTTP::Post::Multipart.new("#{url.path}?#{url.query}",
                                         "file" => UploadIO.new(file_stream, content_type, file_name),
                                         "keywordData" => keywords)

    req.basic_auth @username, @password

    res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
      http.request(req)
    end

#    puts IO.read(docStream)

    res.body
  end


  def get(docId)
    Net::HTTP.start(@url.host, @url.port) do |http|
      req = Net::HTTP::Get.new(@url.path + docId)
      req.basic_auth @username, @password
      http.request(req)
    end
  end

end
