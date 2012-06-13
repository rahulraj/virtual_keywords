if RUBY_VERSION.start_with? '1.8'
  require 'virtual_keywords'
else
  require_relative '../virtual_keywords'
end

# Classes containing code that will be rewritten
# They act as test data for this gem.
require 'virtualizees/parents'
require 'virtualizees/fizzbuzzer'
require 'virtualizees/greeter'
require 'virtualizees/and_user'
require 'virtualizees/or_user'
require 'virtualizees/not_user'
require 'virtualizees/operator_user'
require 'virtualizees/while_user'
require 'virtualizees/until_user'
require 'virtualizees/case_when_user'
require 'virtualizees/micro_sql_dsl'

require 'rspec'

# Helper classes and functions for rewriter specs

# Given a class and a method name, return a sexpified method.
def method_to_sexp(klass, method)
  VirtualKeywords::ParserStrategy.new.translate_instance_method(klass, method)
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

  def my_if
    # Dummy if that increments @my_if_calls, then runs as normal
    @my_if ||= lambda do |condition, then_do, else_do|
      @my_if_calls += 1
      if condition.call 
        then_do.call
      else 
        else_do.call
      end
    end
  end
end

module TrackAnds
  @my_and_calls = 0

  def my_and
    # Dummy if that increments @my_if_calls, then runs as normal
    @my_and ||= lambda do |first, second|
      @my_and_calls += 1
      first.call and second.call
    end
  end
end

module TrackOrs
  @my_or_calls = 0

  def my_or
    @my_or ||= lambda do |first, second|
      @my_or_calls += 1
      first.call or second.call
    end
  end
end

module TrackNots
  @my_not_calls = 0

  def my_not
    @my_not ||= lambda do |value|
      @my_not_calls += 1
      not value.call
    end
  end
end

module TrackWhiles
  @my_while_calls = 0

  def my_while
    @my_while ||= lambda do |condition, body|
      @my_while_calls += 1
      while condition.call
        body.call
      end
    end
  end
end

module TrackUntils
  @my_until_calls = 0

  def my_until
    @my_until ||= lambda do |condition, body|
      @my_until_calls += 1
      until condition.call
        body.call
      end
    end
  end
end

class Abstract < StandardError
end

module DoRewrite
  # Override this and return a list of rewriters, in order, so do_rewrite
  # can call them
  def rewriters
    raise Abstract, 'Must provide rewriters!'
  end

  def do_rewrite(method_name, object, verbose = false,
                 old_and_new_are_same = true)
    sexp = @methods[method_name]
    # Run all rewriters on the sexp
    result = rewriters.reduce(sexp) { |rewritee, rewriter|
      rewriter.process rewritee
    }
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
    object.instance_eval code_result
    #VirtualKeywords::ClassReflection.new.install_method_on_instance(
         #object, code_result)
    new_result = object.send method_name

    if old_and_new_are_same
      new_result.should eql old_result
    end
  end
end

RSpec.configure do |configuration|
  configuration.color_enabled = true
  configuration.formatter = 'documentation'
end
