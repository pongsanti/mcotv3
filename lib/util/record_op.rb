class RecordOp
  def initialize(array, skip)
    @array = array
    @skip = skip
  end

  def split
    return [], [] if @array.empty?
    return @array[0, @skip] || [], @array[@skip, @array.length] || []
  end
end