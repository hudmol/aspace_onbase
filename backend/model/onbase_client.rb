require 'net/http'
require 'net/http/post/multipart'

class OnbaseClient

  def initialize(opts)
    @url = URI.parse('https://onbase-dev.dartmouth.edu/api/OWMROBIInstance/api/documents/')
    @username = 'me'
    @password = 'reallyme'
  end


  def upload(docStream, keywords)

    req = Net::HTTP::Post::Multipart.new @url.path,
    "file" => UploadIO.new(docStream, "image/jpeg", "file.jpg")
    req.basic_auth @username, @password

    res = Net::HTTP.start(@url.host, @url.port) do |http|
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
