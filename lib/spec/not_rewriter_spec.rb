require 'spec_helper'

describe 'NotRewriter' do
  include TrackNots, DoRewrite

  before :each do
    @not_user = NotUser.new true  
    @methods = sexpify_instance_methods NotUser
    @not_rewriter = VirtualKeywords::NotRewriter.new

    @my_not_calls = 0

    VirtualKeywords::REWRITTEN_KEYWORDS.register_lambda_for_object(
        @not_user, :not, my_not)
  end

  def rewriters
    [@not_rewriter]
  end

  it 'rewrites "not" expressions' do
    do_rewrite(:negate, @not_user)
    @my_not_calls.should eql 1
  end
end
