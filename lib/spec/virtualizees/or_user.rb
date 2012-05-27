class OrUser < ApplicationController
  def initialize(value)
    @value = value
  end

  def method_with_or
    @value or false
  end

  def if_with_or
    if @value or true
      'Both @value or true were true (the latter is no surprise)'
    else
      "This can't happen!"
    end
  end
end
