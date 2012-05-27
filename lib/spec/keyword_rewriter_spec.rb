require 'spec_helper'

describe 'KeywordRewriter' do
  before :each do
    #@while_count_sexp = method_to_sexp(WhileUser, :while_count_to_value)
    #@while_result_sexp = method_to_sexp(WhileUser, :while_result)
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
 
  #it 'turns a while into a sexp' do
    #p @while_count_sexp
    #puts ''
    #p @while_result_sexp
  #end
end
