require 'spec_helper'

describe 'ParserStrategy' do
  it 'produces an appropriate strategy object in the factory' do
    VirtualKeywords::ParserStrategy.new.should be_a(
        VirtualKeywords::ParseTreeStrategy)
  end
end

describe 'ParseTreeStrategy' do
  before :each do
    @parse_tree = double 'ParseTree'
    @sexp_processor = double 'SexpProcessor'

    @strategy = VirtualKeywords::ParseTreeStrategy.new(
        @parse_tree, @sexp_processor)
  end

  it 'runs the ParseTree parser, then converts the result into a sexp' do
    klass = :foo
    method_name = :bar
    parse_result = :parsed
    result = :sexp
    @parse_tree.should_receive(:translate).with(klass, method_name).
        and_return parse_result
    @sexp_processor.should_receive(:process).with(parse_result).
        and_return result
    @strategy.translate_instance_method(klass, method_name).should eql result
  end
end
