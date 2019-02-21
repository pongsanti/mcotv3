require 'dotenv/load'
require 'logger'

require_relative 'load_path'
require 'db/connection'
require 'rest/post'

LOG = Logger.new('duplicate_watch.log', 10, 1_024_000)

SELECT_ROW_COUNT = 30
DUPLICATED_CONDITION_ROW_COUNT = 10
LOOP_SLEEP_IN_SECONDS = 15

# select last X rows and count duplicated ocr value
def last_x_rows_ocr_group
  DB["SELECT ocr, COUNT(ocr) AS count FROM (SELECT ocr FROM v3_lists WHERE ocr != '' AND ocr IS NOT NULL LIMIT 30) GROUP BY ocr"]
end

def queryAndPostIfDuplicateFound
  list = last_x_rows_ocr_group.all
  LOG.info "Rows queried: "
  list.each do |row|
    LOG.info row
    ocr = row[:ocr]
    count = row[:count]
    if count >= DUPLICATED_CONDITION_ROW_COUNT
      LOG.info "Found count more than #{DUPLICATED_CONDITION_ROW_COUNT} ocr: #{ocr}"
      Post.new("DUPLICATE!").post
    end
  end
  LOG.info "----- \n"
end

begin
  loop do
    queryAndPostIfDuplicateFound
    sleep LOOP_SLEEP_IN_SECONDS
  end
rescue SignalException => e
  LOG.info e
  LOG.info('Terminating...')
  raise e
end