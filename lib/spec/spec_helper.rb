require 'sexp_processor'
require 'parse_tree'
require 'ruby2ruby'

require 'virtual_keywords/sexp_stringifier'
require 'virtual_keywords/class_mirrorer'
require 'virtual_keywords/virtualizer'
require 'virtual_keywords/keyword_rewriter'
require 'virtual_keywords/rewritten_keywords'

# Classes containing code that will be rewritten
# They act as test data for this gem.
require 'virtualizees/parents'
require 'virtualizees/fizzbuzzer'
require 'virtualizees/greeter'
require 'virtualizees/and_user'
require 'virtualizees/or_user'
require 'virtualizees/operator_user'
require 'virtualizees/while_user'
require 'virtualizees/until_user'
require 'virtualizees/case_when_user'

require 'rspec'

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

module TrackUntils
  @my_until_calls = 0

  def increment_my_until_calls
    @my_until_calls += 1
  end

  def my_until
    @my_until ||= lambda { |condition, body|
      increment_my_until_calls
      until condition.call
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
