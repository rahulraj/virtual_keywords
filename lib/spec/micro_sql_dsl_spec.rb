require 'spec_helper'

describe 'micro SQL DSL rewriting' do
  include TrackIfs, TrackAnds, TrackOrs, DoRewrite

  before :each do
    # Here, MicroSqlUser is the consumer of the DSL.
    @user = MicroSqlUser.new

    @methods = sexpify_instance_methods MicroSqlUser
    @if_rewriter = VirtualKeywords::IfRewriter.new
    @and_rewriter = VirtualKeywords::AndRewriter.new
    @or_rewriter = VirtualKeywords::OrRewriter.new

    @my_if_calls = 0
    @my_and_calls = 0
    @my_or_calls = 0

    VirtualKeywords::REWRITTEN_KEYWORDS.register_lambda_for_object(
        @user, :if, my_if)
    VirtualKeywords::REWRITTEN_KEYWORDS.register_lambda_for_object(
        @user, :and, my_and)
    VirtualKeywords::REWRITTEN_KEYWORDS.register_lambda_for_object(
        @user, :or, my_or)
  end

  def rewriters
    [@if_rewriter, @and_rewriter, @or_rewriter]
  end

  it 'rewrites postfix if in the SQL DSL' do
    do_rewrite(:select_with_where, @user, verbose = false,
        old_and_new_are_same = false)
    @my_if_calls.should eql 1
  end

  it 'rewrites if with or in the SQL DSL' do
    do_rewrite(:select_with_or, @user, verbose = false,
        old_and_new_are_same = false)
    @my_if_calls.should eql 1 
    @my_or_calls.should eql 1
  end

  it 'rewrites complex conditionals in the SQL DSL' do
    do_rewrite(:select_complex, @user, verbose = false,
        old_and_new_are_same = false)
    @my_if_calls.should eql 1 
    @my_and_calls.should eql 1
    @my_or_calls.should eql 1
  end
end

describe 'micro SQL DSL virtualizing' do
  before :each do
    # Here, MicroSqlUser is the consumer of the DSL.
    @user = MicroSqlUser.new
    Sql.dslify @user
  end

  it 'generates basic select statements' do
    result_sql = @user.simple_select
    result_sql.should eql 'select (name,post_ids) from users'
  end

  it 'generates select-where statements' do
    result_sql = @user.select_with_where

    result_sql.should eql 'select (name,post_ids) from users where name="rahul"'
  end

  it 'generates select-where with "or" statements' do
    result_sql = @user.select_with_or
    result_sql.should eql 'select (name,post_ids) from users where ' +
        'name="rahul" or name="Rahul Rajagopalan"'
  end

  it 'handles complex SQL' do
    result_sql = @user.select_complex  
    result_sql.should eql 'select (name,post_ids) from users where ' +
        'name="rahul" and not id=5 or name="Rahul Rajagopalan"'
  end
end
