require 'spec_helper'

describe 'KeywordRewriter' do
  before :each do
    @until = method_to_sexp(UntilUser, :until_count_to_value)
    @until_result = method_to_sexp(UntilUser, :until_result)
  end

  it 'turns an until into a sexp' do
    #p @until    
    #puts ""
    #p @until_result
  end  
end
