describe 'SexpStringifier' do
  before :each do
    @stub_unifier = double 'Unifier'
    @stub_ruby2ruby = double 'Ruby2Ruby'
    @stringifier = VirtualKeywords::SexpStringifier.new(
        @stub_unifier, @stub_ruby2ruby)
  end

  it 'stringifies sexps using unifier and ruby2ruby' do
    sexp = :fake_sexp
    unifier_result = :unified
    final_result = :final
    @stub_unifier.should_receive(:process).with(sexp).
        and_return unifier_result
    @stub_ruby2ruby.should_receive(:process).with(unifier_result).
        and_return final_result
    @stringifier.stringify(sexp).should eql final_result
  end
end
