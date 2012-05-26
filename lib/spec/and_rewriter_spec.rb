require 'spec_helper'

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
