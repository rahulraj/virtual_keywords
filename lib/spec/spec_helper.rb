require 'sexp_processor'
require 'parse_tree'
require 'ruby2ruby'

require 'virtual_keywords/sexp_stringifier'
require 'virtual_keywords/class_mirrorer'
require 'virtual_keywords/virtualizer'
require 'virtual_keywords/keyword_rewriter'
require 'virtual_keywords/rewritten_keywords'

require 'rspec'

# Classes the specs should use.
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

  def greet_block
    # Multiple statements in the if/else clauses
    if @hello
      value = 5
      value += 5

      value
    else
      thing = 9

      thing
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

  def until_result
    my_until(
        lambda { @i > @value },
        lambda do
          @counts << @i
          @i += 1
        end
    )
    @counts
  end
end

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

# Helper classes and functions for rewriter specs

# Given a class and a method name, return a sexpified method.
def method_to_sexp(klass, method)
  SexpProcessor.new.process(ParseTree.translate(klass, method))
end

# Sexpify all non-inherited instance methods of a class and return them in
# a hash mapping names to sexps.
def sexpify_instance_methods klass
  sexps = {}
  klass.instance_methods(false).each do |method_name|
    sexps[method_name.to_sym] = method_to_sexp(klass, method_name.to_sym)
  end

  sexps
end

module TrackIfs
  @my_if_calls = 0 # Don't forget to reset this before each spec!

  def increment_my_if_calls
    @my_if_calls += 1
  end

  def my_if
    # Dummy if that increments @my_if_calls, then runs as normal
    @my_if ||= lambda { |condition, then_do, else_do|
      increment_my_if_calls
      if condition.call 
        then_do.call
      else 
        else_do.call
      end
    }
  end
end

module TrackAnds
  @my_and_calls = 0

  def increment_my_and_calls
    @my_and_calls += 1
  end

  def my_and
    # Dummy if that increments @my_if_calls, then runs as normal
    @my_and ||= lambda { |first, second|
      increment_my_and_calls
      first.call and second.call
    }
  end
end

module TrackOrs
  @my_or_calls = 0

  def increment_my_or_calls
    @my_or_calls += 1
  end

  def my_or
    @my_or ||= lambda { |first, second|
      increment_my_or_calls
      first.call or second.call
    }
  end
end

module TrackWhiles
  @my_while_calls = 0

  def increment_my_while_calls
    @my_while_calls += 1
  end

  def my_while
    @my_while ||= lambda { |condition, body|
      increment_my_while_calls
      while condition.call
        body.call
      end
    }
  end
end

class Abstract < StandardError
end

module DoRewrite
  # Override this and return a list of rewriters, in order, so do_rewrite
  # can call them
  def rewriters
    raise Abstract
  end

  def do_rewrite(method_name, object, verbose = false)
    sexp = @methods[method_name]
    result = sexp
    rewriters.each do |rewriter|
      result = rewriter.process result 
    end
    stringifier = VirtualKeywords::SexpStringifier.new

    # Visually inspecting this result, it appears to be right
    code_result = stringifier.stringify result
    if verbose
      puts code_result
    end

    # my_* are  dummy methods that do not change behavior, so both the
    # old and new code should produce the same result,
    # except that @my_*_calls is incremented
    old_result = object.send method_name
    VirtualKeywords::ClassReflection.install_method_on_instance(object, code_result)
    new_result = object.send method_name

    new_result.should eql old_result
  end
end

RSpec.configure do |configuration|
  configuration.color_enabled = true
  configuration.formatter = 'documentation'
end
