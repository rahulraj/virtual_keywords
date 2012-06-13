require 'spec_helper'

describe 'ClassMirrorer' do
  before :each do
    @stub_parser = double 'parser'
    @mirrorer = VirtualKeywords::ClassMirrorer.new :parser => @stub_parser
  end

  it 'mirrors given classes' do
    @stub_parser.stub(:translate_instance_method).and_return :translated
    result = @mirrorer.mirror  Fizzbuzzer
    
    class_and_method = VirtualKeywords::ClassAndMethodName.new(
        Fizzbuzzer, :fizzbuzz)
    result.keys.should include class_and_method
    result[class_and_method].should eql :translated
  end
end
