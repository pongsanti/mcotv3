require 'file/file_op'
require 'post_process/post_processor'
require 'tesseract/ocr'
require 'rest/post'

# First model
class V3List < Sequel::Model
  REGEX = /^(SET|SETS?[5|S][0|O]) (\d{1,3},[\d\/]{3}[.]\d{2}|[\d\/]{3}[.]\d{2}) (.{1,2}) (\d{1,3}[.]\d{2})$/
  SUFFIX = '_c'.freeze

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
    save
    #fop = FileOp.new(filename)
    #fop.delete
    #fop.name_suffix(SUFFIX).delete
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
    Post.new(normalized, filename).post
    self.posted = 1
    save
  end

  def skip_step
    return 26 if ocr_start('SET50 Val')
    return 22 if ocr_start('SET100 Val')
    return 24 if ocr_start('SET100')
    return 18 if ocr_start('sSET Val') || ocr_start('SSET Val')
    return 20 if ocr_start('sSET') || ocr_start('SSET')
    return 14 if ocr_start('SETHD Val')
    return 16 if ocr_start('SETHD')
    return 10 if ocr_start('SETCLMV Val')
    return 12 if ocr_start('SETCLMV')
    return 6 if ocr_start('SETTHSI Val')
    return 8 if ocr_start('SETTHSI')
    return 2 if ocr_start('mai Val')
    return 4 if ocr_start('mai')
    0 # found! don't skip
  end

  def ocr_start(s)
    ocr.start_with?(s)
  end

  def set_or_set50?
    ocr =~ REGEX
  end
end
