require 'file/file_op'
require 'post_process/post_processor'
require 'tesseract/ocr'
require 'rest/post'

# First model
class V3List < Sequel::Model
  REGEX = /(SET|SET[5|S][0|O]) (\d{1,3},\d{3}.\d{2}|\d{3}.\d{2}) (.{1}) (\d{1,3}.\d{2})/
  SUFFIX = '_c'

  set_primary_key :rowid

  class << self
    def sel
      select(:rowid, :filename, :ocr, :normalized, :posted, :valid)
    end

    def valid_not_posted
      sel.where(valid: 1, posted: 0).order(:rowid)
    end
  end

  def invalid
    self.valid = 0
    self.save
    fop = FileOp.new(filename)
    fop.delete
    fop.name_suffix(SUFFIX).delete
  end

  def do_ocr
    fop = FileOp.new(filename).name_suffix(SUFFIX)
    self.ocr = Ocr.new(fop).parse
  end

  def post_process_and_post_to_server
    do_post_process
    do_post
  end

  def do_post_process
    self.normalized = PostProcessor.new(ocr).normalize
  end

  def do_post
    Post.new(self.normalized, self.filename).post
  end

  def skip_step
    if ocr_start('SET50 Val')
      return 18
    elsif ocr_start('SET100 Val')
      return 14
    elsif ocr_start('SET100')
      return 16
    elsif ocr_start('sSET Val') || ocr_start('SSET Val')
      return 10
    elsif ocr_start('sSET') || ocr_start('SSET')
      return 12
    elsif ocr_start('SETHD Val')
      return 6
    elsif ocr_start('SETHD')
      return 8
    elsif ocr_start('mai Val')
      return 2
    elsif ocr_start('mai')
      return 4
    else
      return 0 # found! don't skip
    end
  end

  def ocr_start(s)
    ocr.start_with?(s)
  end

  def is_set_or_set50
    self.ocr =~ REGEX
  end
end
