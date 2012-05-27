class CaseWhenUser < ApplicationController
  def initialize(value)
    @value = value
  end

  def describe_value
    case @value
      when 1
        :one
      when 3..5
        :three_to_five
      when 7, 9
        :seven_or_nine
      when value * 10 < 90
        :passes_multiplication_test
      else
        :something_else
    end
  end
end
