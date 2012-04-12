require 'replacements'

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

  # An example conditional: if and else
  def greet_if_else
    if @hello
      'Hello World! (if else)'
    else
      # Compound expressions should be preserved
      # (i.e. not evaluated too early or in the wrong context)
      'Good' + 'bye (if else)'
    end
  end

  # If without else
  def greet_if_without_else
    if @hello
      'Hello World! (if without else)'
    end
  end

  # Postfix if
  def greet_postfix_if
    'Hello World! (postfix if)' if @hello
  end

  # If, then, else
  def greet_if_then_else
    if @hello then 'Hello World! (if then else)' else 'Goodbye (if then else)' end
  end

  # If, then, no else
  def greet_if_then_no_else
    if @hello then 'Hello World! (if then)' end
  end

  # Unless
  def greet_unless
    unless @hello
      'Goodbye (unless)'
    end
  end

  # Unless, then else
  def greet_unless_else
    unless @hello
      'Goodbye (unless else)'
    else
      'Hello World! (unless else)'
    end
  end

  # Postfix unless
  def greet_postfix_unless
    'Goodbye (postfix unless)' unless @hello
  end

  # What the conditional in greet should look like after processing
  def greet_changed
    my_if(lambda { @hello }, lambda { 'Hello World!' },
          lambda { 'Good' + 'bye' })
  end

  # All together now
  def greet_all
    result = ''
    # 1
    if @hello
      result = 'Hello'
    else
      result = 'Goodbye'
    end
    # 2
    if 2 + 2 == 4
      result += '\nMath is right'
    end
    # 3
    result += '\nThis is supposed to look like English' if false
    # 4
    unless 2 + 9 == 10
      result += '\nMath should work in unless too'
    end
    # 5
    result += '\nWorld!' unless true

    result
  end

  def greet_nested
    if true
      # This if should be processed, even though it never happens!
      if 2 + 2 == 4
        'Math is right'
      else
        'Weird'
      end
    else
      # This if should be expanded, but NOT evaluated!
      puts 'hi there' if true
      'The false case'
    end
  end

  def count_to_ten
    [1..10].each do |index|
      puts index
    end
  end
end

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

  def method_with_and_result
    my_and(lambda { @value }, lambda { true })
  end
end

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
