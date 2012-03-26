require 'my_if'

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

  # The following two methods are before/after examples. The rewriter
  # should turn greet's body into greet_changed's. Running ParseTree over
  # them, I got two sexps (in sexps_greet.txt), which I read to
  # reverse-engineer the format. There may be edge cases (Ruby's grammar
  # is much more complex than Lisp's!)
  #
  # spec/if_processor_spec runs a test over greet

  # An example conditional
  def greet
    if @hello
      'Hello World!'
    else
      # Compound expressions should be preserved
      # (i.e. not evaluated too early or in the wrong context)
      'Good' + 'bye'
    end
  end

  # What the conditional in greet should look like after processing
  def greet_changed
    my_if(lambda { @hello }, lambda { 'Hello World!' },
          lambda { 'Good' + 'bye' })
  end

  def count_to_ten
    [1..10].each do |index|
      puts index
    end
  end
end
