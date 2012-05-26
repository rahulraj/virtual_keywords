require 'spec_helper'

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

describe 'IfRewriter' do
  include TrackIfs, DoRewrite

  before :each do
    @greeter = Greeter.new true
    @methods = sexpify_instance_methods Greeter
    @if_rewriter = VirtualKeywords::IfRewriter.new

    @my_if_calls = 0

    VirtualKeywords::REWRITTEN_KEYWORDS.register_lambda_for_object(
        @greeter, :if, my_if)
  end

  def rewriters
    [@if_rewriter]
  end

  def greeter_rewrite_should_work(method_name,
      required_calls = 1, verbose = false)
    do_rewrite(method_name, @greeter, verbose = verbose)
    @my_if_calls.should eql required_calls
  end

  it 'rewrites greet with if and else' do
    greeter_rewrite_should_work :greet_if_else
  end

  it 'rewrites greet with if without else' do
    # We don't need to do anything special for if without else
    # They use the same sexp as if with else, with an empty block for the
    # else clause
    greeter_rewrite_should_work :greet_if_without_else
  end

  it 'rewrites greet with postfix if' do
    # Again, we don't need to do anything special - they turn into the same sexp
    greeter_rewrite_should_work :greet_postfix_if
  end

  it 'rewrites greet with if then else on one line' do
    greeter_rewrite_should_work :greet_if_then_else
  end

  it 'rewrites greet with if then but no else on one line' do
    greeter_rewrite_should_work :greet_if_then_no_else
  end

  it 'rewrites greet with unless' do
    greeter_rewrite_should_work :greet_unless
  end

  it 'rewrites greet with unless and else' do
    greeter_rewrite_should_work :greet_unless_else
  end

  it 'rewrites greet with postfix unless' do
    greeter_rewrite_should_work :greet_postfix_unless
  end

  it 'combines ifs without interference' do
    greeter_rewrite_should_work(:greet_all, required_calls = 5)
  end

  it 'handles nested ifs' do
    greeter_rewrite_should_work(:greet_nested, required_calls = 2)
  end
end

describe 'AndRewriter' do
  include TrackIfs, TrackAnds, DoRewrite

  before :each do
    @and_user = AndUser.new false
    @methods = sexpify_instance_methods AndUser
    @if_rewriter = VirtualKeywords::IfRewriter.new
    @and_rewriter = VirtualKeywords::AndRewriter.new

    @my_and_calls = 0
    @my_if_calls = 0

    VirtualKeywords::REWRITTEN_KEYWORDS.register_lambda_for_object(
        @and_user, :and, my_and)
    VirtualKeywords::REWRITTEN_KEYWORDS.register_lambda_for_object(
        @and_user, :if, my_if)
  end

  def rewriters
    [@if_rewriter, @and_rewriter]
  end

  it 'rewrites "and" statements' do
    do_rewrite(:method_with_and, @and_user)
    @my_and_calls.should eql 1
  end

  it 'handles ifs with "and"s in the predicate' do
    do_rewrite(:if_with_and, @and_user)
    @my_and_calls.should eql 1
    @my_if_calls.should eql 1
  end
end

describe 'OrRewriter' do
  include TrackIfs, TrackOrs, DoRewrite

  before :each do
    @or_user = OrUser.new true
    @methods = sexpify_instance_methods OrUser
    @if_rewriter = VirtualKeywords::IfRewriter.new
    @or_rewriter = VirtualKeywords::OrRewriter.new

    @my_if_calls = 0
    @my_or_calls = 0

    VirtualKeywords::REWRITTEN_KEYWORDS.register_lambda_for_object(
        @or_user, :or, my_or)
    VirtualKeywords::REWRITTEN_KEYWORDS.register_lambda_for_object(
        @or_user, :if, my_if)
  end

  def rewriters
    [@if_rewriter, @or_rewriter]
  end

  it 'rewrites "or" statements' do
    do_rewrite(:method_with_or, @or_user)
    @my_or_calls.should eql 1
  end

  it 'handles ifs with "or"s in the predicate' do
    do_rewrite(:if_with_or, @or_user)
    @my_or_calls.should eql 1
    @my_if_calls.should eql 1
  end
end

describe 'AndRewriter on &&' do
  include TrackAnds, DoRewrite

  before :each do
    @operator_user = OperatorUser.new false
    @methods = sexpify_instance_methods OperatorUser
    @and_rewriter = VirtualKeywords::AndRewriter.new

    @my_and_calls = 0

    VirtualKeywords::REWRITTEN_KEYWORDS.register_lambda_for_object(
        @operator_user, :and, my_and)
  end

  def rewriters
    [@and_rewriter]
  end

  it 'rewrites &&' do
    do_rewrite(:symbolic_and, @operator_user)
    @my_and_calls.should eql 1
  end
end

describe 'KeywordRewriter' do
  before :each do

    @while_count_sexp = method_to_sexp(WhileUser, :while_count_to_value)


  end

  # These two "specs" produce sexps that I used to figure out how
  # to do the rewrite. Their outputs are in sexps_greet.txt and
  # count_to_ten_sexp.txt
  
  #it 'compares sexps of manually translated if' do
    #puts 'before translation'
    #p @greet_if_else_sexp
    #puts ''

    #puts 'after translation'
    #p @greet_changed_sexp
    #puts ''
  #end

  #it 'turns a method with block code into a sexp' do
    #count_sexp = method_to_sexp(Greeter, :count_to_ten)
    #p count_sexp
  #end
  
  # Spec used to see how "and" should be translated
  #it 'compares sexps of manually translated and' do
    #puts 'before'
    #p @method_with_and_sexp
    #puts ''

    #puts 'after'
    #p @method_with_and_result_sexp
    #puts ''
  #end
  
  # Spec used to see how && should be translated
  # Looks like it uses :and same as the other one
  # Aren't they different semantically though?
  #it 'compares sexps of manually translated &&' do
    #puts 'before'
    #p @symbolic_and_sexp
    #puts ''

    #puts 'after'
    #p @symbolic_and_result_sexp
    #puts ''
  #end

  #it 'turns a case-when into a sexp' do
    #p @describe_value_sexp  
  #end
 
  it 'turns a while into a sexp' do
    p @while_count_sexp
  end
end
