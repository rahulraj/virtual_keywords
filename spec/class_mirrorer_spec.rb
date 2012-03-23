require 'spec_helper'

describe 'class_mirrorer' do
  before :each do
    @stub_parser = double('parser')
  end

  it 'should produce a lambda mirroring given classes' do
    @stub_parser.stub(:translate).and_return('translated') 
    mirrorer = new_class_mirrorer(@stub_parser)
    result = mirrorer.call [Fizzbuzzer]
    
    class_and_method = ClassAndMethodName.new(Fizzbuzzer, 'fizzbuzz')
    result.keys.should include class_and_method
    result[class_and_method].should eql 'translated'
  end
end
