require 'spec_helper'

describe 'WhileRewriter' do
  include TrackWhiles, DoRewrite

  before :each do
    @while_user = WhileUser.new 10
    @methods = sexpify_instance_methods WhileUser
    @while_rewriter = VirtualKeywords::WhileRewriter.new

    @my_while_calls = 0

    VirtualKeywords::REWRITTEN_KEYWORDS.register_lambda_for_object(
        @while_user, :while, my_while)
  end

  def rewriters
    [@while_rewriter]
  end
 
  it 'rewrites "while" expressions' do
    do_rewrite(:while_count_to_value, @while_user) 
    @my_while_calls.should eql 1
  end
end

describe 'WhileRewriter on untils' do
  include TrackWhiles, DoRewrite

  before :each do
    @until_user = UntilUser.new 10
    @methods = sexpify_instance_methods UntilUser
    @while_rewriter = VirtualKeywords::WhileRewriter.new

    @my_while_calls = 0

    VirtualKeywords::REWRITTEN_KEYWORDS.register_lambda_for_object(
        @until_user, :while, my_while)
  end

  def rewriters
    [@while_rewriter]
  end
 
  xit 'rewrites "until" expressions' do
    do_rewrite(:until_count_to_value, @until_user)
    @my_while_calls.should eql 1
  end
  
end
