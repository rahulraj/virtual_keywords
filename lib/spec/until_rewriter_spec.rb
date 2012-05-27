require 'spec_helper'

describe 'UntilRewriter' do
  include TrackUntils, DoRewrite

  before :each do
    @until_user = UntilUser.new 10
    @methods = sexpify_instance_methods UntilUser
    @until_rewriter = VirtualKeywords::UntilRewriter.new

    @my_until_calls = 0

    VirtualKeywords::REWRITTEN_KEYWORDS.register_lambda_for_object(
        @until_user, :until, my_until)
  end

  def rewriters
    [@until_rewriter]
  end
 
  it 'rewrites "until" expressions' do
    do_rewrite(:until_count_to_value, @until_user)
    @my_until_calls.should eql 1
  end
  
end
