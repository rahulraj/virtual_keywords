class AndUser < ActiveRecord::Base
  def initialize(value)
    @value = value
  end

  def method_with_and
    @value and true
  end

  def if_with_and
    if @value and true
      'Both @value and true were true (the latter is no surprise)'
    else
      '@value must have been false, I doubt true was false!'
    end
  end
end
