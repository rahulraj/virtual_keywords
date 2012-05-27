require 'spec_helper'

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

  it 'rewrites ifs with compound clauses' do
    greeter_rewrite_should_work :greet_block
  end
end
