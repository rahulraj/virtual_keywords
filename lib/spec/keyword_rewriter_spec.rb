require 'spec_helper'

describe 'KeywordRewriter' do
  before :each do
    @sexp_processor = SexpProcessor.new

    def method_to_sexp(klass, method)
      @sexp_processor.process(ParseTree.translate(klass, method))
    end

    @greeter = Greeter.new true
    @and_user = AndUser.new false
    @or_user = OrUser.new true
    @operator_user = OperatorUser.new false
    @while_user = WhileUser.new 5
    @case_when_user = CaseWhenUser.new 6

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


    @method_with_and_sexp = method_to_sexp(AndUser, :method_with_and)
    @if_with_and_sexp = method_to_sexp(AndUser, :if_with_and)

    @method_with_or_sexp = method_to_sexp(OrUser, :method_with_or)
    @if_with_or_sexp = method_to_sexp(OrUser, :if_with_or)

    @symbolic_and_sexp = method_to_sexp(OperatorUser, :symbolic_and)

    @greet_changed_sexp = method_to_sexp(Greeter, :greet_changed)
    @method_with_and_result_sexp = method_to_sexp(AndUser,
                                                  :method_with_and_result)
    @symbolic_and_result_sexp = method_to_sexp(OperatorUser,
                                               :symbolic_and_result)

    @while_count_sexp = method_to_sexp(WhileUser, :while_count_to_value)

    @describe_value_sexp = method_to_sexp(CaseWhenUser, :describe_value)

    @if_rewriter = VirtualKeywords::IfRewriter.new
    @and_rewriter = VirtualKeywords::AndRewriter.new
    @or_rewriter = VirtualKeywords::OrRewriter.new

    @my_if_calls = 0
    def increment_my_if_calls
      @my_if_calls += 1
    end

    @my_and_calls = 0
    def increment_my_and_calls
      @my_and_calls += 1
    end
    @my_or_calls = 0
    def increment_my_or_calls
      @my_or_calls += 1
    end
    $my_symbolic_and_calls = 0

    spec = self
    my_if = lambda { |condition, then_do, else_do|
      increment_my_if_calls()
      if condition.call 
        then_do.call
      else 
        else_do.call
      end
    }
    my_and = lambda { |first, second|
      increment_my_and_calls()
      first.call and second.call
    }
    my_or = lambda { |first, second|
      increment_my_or_calls()
      first.call or second.call
    }
  
    VirtualKeywords::REWRITTEN_KEYWORDS.register_lambda_for_object(
        @greeter, :if, my_if)
    
    VirtualKeywords::REWRITTEN_KEYWORDS.register_lambda_for_object(
        @and_user, :and, my_and)

    VirtualKeywords::REWRITTEN_KEYWORDS.register_lambda_for_object(
        @and_user, :if, my_if)

    VirtualKeywords::REWRITTEN_KEYWORDS.register_lambda_for_object(
        @or_user, :or, my_or)

    VirtualKeywords::REWRITTEN_KEYWORDS.register_lambda_for_object(
        @or_user, :if, my_if)

    VirtualKeywords::REWRITTEN_KEYWORDS.register_lambda_for_object(
        @operator_user, :and, my_and)
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
 
  it 'turns a while into a sexp' do
    p @while_count_sexp
  end

  def do_rewrite(sexp, method_name, object, verbose = false)
    result1 = @if_rewriter.process sexp
    result2 = @and_rewriter.process result1
    result = @or_rewriter.process result2
    stringifier = VirtualKeywords::SexpStringifier.new

    # Visually inspecting this result, it appears to be right
    code_result = stringifier.stringify result
    if verbose
      puts code_result
    end

    # my_* are  dummy methods that do not change behavior, so both the
    # old and new code should produce the same result,
    # except that @my_*_calls is incremented
    old_result = object.send method_name
    VirtualKeywords::ClassReflection.install_method_on_instance(object, code_result)
    new_result = object.send method_name

    new_result.should eql old_result
  end

  def greeter_rewrite_should_work(sexp, method_name,
                                  required_calls = 1, verbose = false)
    do_rewrite(sexp, method_name, @greeter, verbose = verbose)
    @my_if_calls.should eql required_calls
  end

  it 'rewrites greet with if and else' do
    greeter_rewrite_should_work(@greet_if_else_sexp, :greet_if_else)
  end

  it 'rewrites greet with if without else' do
    # We don't need to do anything special for if without else
    # They use the same sexp as if with else, with an empty block for the
    # else clause
    greeter_rewrite_should_work(@greet_if_without_else_sexp,
                                :greet_if_without_else)
  end

  it 'rewrites greet with postfix if' do
    # Again, we don't need to do anything special - they turn into the same sexp
    greeter_rewrite_should_work(@greet_postfix_if_sexp, :greet_postfix_if)
  end

  it 'rewrites greet with if then else on one line' do
    greeter_rewrite_should_work(@greet_if_then_else_sexp,
                                :greet_if_then_else)
  end

  it 'rewrites greet with if then but no else on one line' do
    greeter_rewrite_should_work(@greet_if_then_no_else_sexp,
                                :greet_if_then_no_else)
  end

  it 'rewrites greet with unless' do
    greeter_rewrite_should_work(@greet_unless_sexp, :greet_unless)    
  end

  it 'rewrites greet with unless and else' do
    greeter_rewrite_should_work(@greet_unless_else_sexp, :greet_unless_else)
  end

  it 'rewrites greet with postfix unless' do
    greeter_rewrite_should_work(@greet_postfix_unless_sexp,
                                :greet_postfix_unless)
  end

  it 'combines ifs without interference' do
    greeter_rewrite_should_work(@greet_all_sexp, :greet_all, required_calls = 5)
  end

  it 'handles nested ifs' do
    greeter_rewrite_should_work(@greet_nested_sexp, :greet_nested,
                                required_calls = 2)
  end

  it 'rewrites "and" statements' do
    do_rewrite(@method_with_and_sexp, :method_with_and, @and_user)
    @my_and_calls.should eql 1
  end

  it 'handles ifs with "and"s in the predicate' do
    do_rewrite(@if_with_and_sexp, :if_with_and, @and_user)
    @my_and_calls.should eql 1
    @my_if_calls.should eql 1
  end

  it 'rewrites "or" statements' do
    do_rewrite(@method_with_or_sexp, :method_with_or, @or_user)
    @my_or_calls.should eql 1
  end

  it 'handles ifs with "or"s in the predicate' do
    do_rewrite(@if_with_or_sexp, :if_with_or, @or_user)
    @my_or_calls.should eql 1
    @my_if_calls.should eql 1
  end

  it 'rewrites &&' do
    do_rewrite(@symbolic_and_sexp, :symbolic_and, @operator_user)
    @my_and_calls.should eql 1
  end
end
