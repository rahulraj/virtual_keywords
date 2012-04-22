describe 'RewrittenKeywords' do
  before :each do
    @rewritten_keywords = VirtualKeywords::RewrittenKeywords.new({}) 
  end

  it 'has no lambdas initially' do
    lambda { @rewritten_keywords.lambda_or_raise(4, :if) }.
        should raise_error VirtualKeywords::RewriteLambdaNotProvided
  end

  it 'registers lambdas for objects' do
    number = 5 
    keyword = :if
    the_lambda = lambda {}
    @rewritten_keywords.register_lambda_for_object(number, keyword, the_lambda)
    @rewritten_keywords.lambda_or_raise(number, keyword).should eql the_lambda
  end

  it 'registers lambdas for classes' do
    class MyClass
    end
    my_class = MyClass.new
    keyword = :if
    the_lambda = lambda {}
    @rewritten_keywords.register_lambda_for_class(MyClass, keyword, the_lambda)
    @rewritten_keywords.lambda_or_raise(my_class, keyword).should eql the_lambda
  end
end
