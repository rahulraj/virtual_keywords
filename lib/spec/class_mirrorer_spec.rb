require 'spec_helper'

describe 'ClassMirrorer' do
  before :each do
    @stub_parser = double('parser')
  end

  it 'mirrors given classes' do
    @stub_parser.stub(:translate).and_return('translated') 
    mirrorer = VirtualKeywords::ClassMirrorer.new @stub_parser
    result = mirrorer.mirror [Fizzbuzzer]
    
    class_and_method = VirtualKeywords::ClassAndMethodName.new(
        Fizzbuzzer, 'fizzbuzz')
    result.keys.should include class_and_method
    result[class_and_method].should eql 'translated'
  end
end
