require 'dotenv/load'
require 'logger'

require_relative 'load_path'
require 'db/connection'
require 'rest/post'
require 'util/record_op'

LOG = Logger.new('select.log', 10, 1_024_000)

def skip_and_compute(recs)
  LOG.info "Record size: #{recs.length}"
  return recs if recs.empty?

  first = recs.shift
  first.do_ocr
  LOG.info "Skip size: #{first.skip_step}"
  if first.skip_step.zero?
    handle_no_skip(first)
    recs
  else
    # skipping records
    skips, new_recs = RecordOp.new(recs, first.skip_step).split

    skips.unshift(first)
    handle_skips(skips)
    new_recs
  end
end

def handle_no_skip(rec)
  if rec.is_set_or_set50
    LOG.info "Found value: #{rec.ocr}"
    LOG.info "Normalized as: #{rec.normalized}"
    rec.post_process_and_post_to_server
    LOG.info '---'
  else
    handle_skips([rec])
  end
end

def handle_skips(recs)
  recs.each do |rec|
    LOG.info "Set to invalid #{rec.id}:#{rec.filename}"
    rec.invalid
  end
end

begin
  loop do
    list = V3List.valid_not_posted.all
    new_recs = skip_and_compute(list)
    new_recs = skip_and_compute(new_recs) until new_recs.empty?

    LOG.info '-----'
    sleep 5
  end
rescue SignalException => e
  LOG.info e
  LOG.info('Terminating...')
  raise e
end
