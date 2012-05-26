require 'spec_helper'

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
