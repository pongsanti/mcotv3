require 'rest_client'
require 'file/file_op'
# Post multipart form data
class Post
  URL = ENV['POST_URL']
  CLIENT = ENV['CLIENT']
  
  def initialize(value, filename = nil)
    @value = value
    unless filename.nil?
      @file_op = FileOp.new(filename)
      @cropfile_op = @file_op.name_suffix('_c')
    end
  end

  def post
    success = true

    begin
      if @file_op.nil?
        RestClient.post(URL, article: { text: @value, client: CLIENT })
      else
        RestClient.post(URL,
          article: { text: @value,
                    file: File.new(@file_op.path, 'rb'),
                    crop_file: File.new(@cropfile_op.path, 'rb'),
                    client: CLIENT }
        )
      end
      LOG.info "Posted to the server."
    rescue StandardError => err
      puts err
      success = false
    end
    success
  end
end
