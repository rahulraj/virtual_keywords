class UntilUser
  def initialize(value)
    @value = value
    @i = 0
    @counts = []
  end

  def until_count_to_value
    until @i > @value
      @counts << @i
      @i += 1
    end

    @counts
  end
end
