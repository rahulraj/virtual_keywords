class WhileUser < ApplicationController
  def initialize(value)
    @value = value
    @i = 0
    @counts = []
  end

  def while_count_to_value
    while @i < @value
      @counts << @i
      @i += 1
    end

    @counts
  end
end
