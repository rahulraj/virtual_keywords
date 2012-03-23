# Stub "Rails" classes
module ActiveRecord
  class Base
  end
end

class ApplicationController
end

class Fizzbuzzer < ActiveRecord::Base
  def fizzbuzz(n)
    (1..n).map { |i|
      if i % 3 == 0 and i % 5 == 0
        "fizzbuzz"
      elsif i % 3 == 0
        "fizz"
      elsif i  % 5 == 0
        "buzz"
      else
        i.to_s
      end
    }
  end
end

class Greeter < ApplicationController
  def initialize(hello)
    @hello = hello
  end

  def greet
    if @hello
      'Hello World!'
    else
      'Goodbye'
    end
  end
end
