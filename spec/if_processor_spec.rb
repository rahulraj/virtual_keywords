require 'spec_helper'

describe 'if_processor' do

  before :each do
    @sexp_processor = SexpProcessor.new

    def method_to_sexp(klass, method)
      translated = ParseTree.translate(klass, method)

      @sexp_processor.process translated
    end

    @greeter = Greeter.new true

    @greet_if_else_sexp = method_to_sexp(Greeter, :greet_if_else)
    @greet_if_without_else_sexp = method_to_sexp(Greeter,
                                                 :greet_if_without_else)
    @greet_postfix_if_sexp = method_to_sexp(Greeter, :greet_postfix_if)
    @greet_if_then_else_sexp = method_to_sexp(Greeter, :greet_if_then_else)
    @greet_if_then_no_else_sexp = method_to_sexp(Greeter,
                                                 :greet_if_then_no_else)
    @greet_unless_sexp = method_to_sexp(Greeter, :greet_unless)
    @greet_unless_else_sexp = method_to_sexp(Greeter, :greet_unless_else)
    @greet_postfix_unless_sexp = method_to_sexp(Greeter, :greet_postfix_unless)
    @greet_all_sexp = method_to_sexp(Greeter, :greet_all)
    @greet_nested_sexp = method_to_sexp(Greeter, :greet_nested)

    @greet_changed_sexp = method_to_sexp(Greeter, :greet_changed)

    @method_with_and_sexp = method_to_sexp(Greeter, :method_with_and)
    @method_with_and_result_sexp = method_to_sexp(Greeter,
                                                  :method_with_and_result)

    @if_processor = IfProcessor.new

    # TODO Use mocking on my_if instead of this global variable
    $my_if_calls = 0
  end

  # These two "specs" produce sexps that I used to figure out how
  # to do the rewrite. Their outputs are in sexps_greet.txt and
  # count_to_ten_sexp.txt
  
  #it 'compares sexps of manually translated if' do
    #puts 'before translation'
    #p @greet_sexp
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
  
  def greet_variation_should_work(sexp, method_name, if_calls = 1,
                                  verbose = false)
    result = @if_processor.process sexp

    # Visually inspecting this result, it appears to be right
    code_result = sexp_to_string result
    if verbose
      puts code_result
    end

    # my_if is a dummy method that does not change behavior, so both the
    # old and new code should produce the same result (greet is referentially
    # transparent), except that $my_if_calls is incremented
    old_result = @greeter.send method_name
    @greeter.instance_eval code_result # Put in the new method
    new_result = @greeter.send method_name

    new_result.should eql old_result
    $my_if_calls.should eql if_calls
  end
 
  it 'should process greet with if and else' do
    greet_variation_should_work(@greet_if_else_sexp, :greet_if_else)
  end

  it 'should process greet with if without else' do
    # We don't need to do anything special for if without else
    # They use the same sexp as if with else, with an empty block for the
    # else clause
    greet_variation_should_work(@greet_if_without_else_sexp,
                                :greet_if_without_else)
  end

  it 'should process greet with postfix if' do
    # Again, we don't need to do anything special - they turn into the same sexp
    greet_variation_should_work(@greet_postfix_if_sexp, :greet_postfix_if)
  end

  it 'should process greet with if then else on one line' do
    greet_variation_should_work(@greet_if_then_else_sexp,
                                :greet_if_then_else)
  end

  it 'should process greet with if then but no else on one line' do
    greet_variation_should_work(@greet_if_then_no_else_sexp,
                                :greet_if_then_no_else)
  end

  it 'should process greet with unless' do
    greet_variation_should_work(@greet_unless_sexp, :greet_unless)    
  end

  it 'should process greet with unless and else' do
    greet_variation_should_work(@greet_unless_else_sexp, :greet_unless_else)
  end

  it 'should process greet with postfix unless' do
    greet_variation_should_work(@greet_postfix_unless_sexp,
                                :greet_postfix_unless)
  end

  it 'should combine ifs without interference' do
    greet_variation_should_work(@greet_all_sexp, :greet_all, 5)
  end

  it 'should handle nested ifs' do
    greet_variation_should_work(@greet_nested_sexp, :greet_nested, 2)
  end
end
