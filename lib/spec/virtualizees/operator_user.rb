# Ruby also lets you use the && and || operators
# I think they have different precedence rules
class OperatorUser < ActiveRecord::Base
  def initialize(value)
    @value = value
  end

  def symbolic_and
    @value && false
  end

  def symbolic_and_result
    my_conditional_and(lambda { @value }, lambda { false })
  end
end
