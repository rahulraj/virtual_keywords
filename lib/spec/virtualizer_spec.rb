require 'spec_helper'

describe 'Virtualizer' do
  before :each do
    @greeter = Greeter.new false

    class MyClass
      def foo
        if (2 + 2) == 4 and false
          :tampered_and
        else
          :original
        end
      end

      def bar
        if (2 + 2) == 4 or false        
          :original
        else
          :tampered_or
        end
      end
    end

    class AnotherClass
      def quux
        if true then :right else :if_modified end
      end
    end

    class YetAnotherClass < AnotherClass
      def quux
        if false then :if_modified else :right end
      end
    end

    class WhileCounter
      def run
        a = []
        i = 0
        while i <= 10
          a << i
        end

        a
      end
    end

    class UntilCounter
      def run
        a = []
        i = 0
        until i > 10
          a << i
        end

        a
      end
    end

    class Inverter
      def run value
        not value
      end
    end

    @my_class = MyClass.new
    @another_class = AnotherClass.new
    @yet_another_class = YetAnotherClass.new
    @operator_user = OperatorUser.new false
    @while_counter = WhileCounter.new
    @until_counter = UntilCounter.new
    @inverter = Inverter.new
    @virtualizer = VirtualKeywords::Virtualizer.new(
        :for_instances => [@greeter, @my_class,
            @while_counter, @until_counter, @inverter]
    )
    @class_virtualizer = VirtualKeywords::Virtualizer.new(
        :for_classes => [AnotherClass]
    )
    @subclass_virtualizer = VirtualKeywords::Virtualizer.new(
        :for_subclasses_of => [AnotherClass]
    )
    @rails_subclass_virtualizer = VirtualKeywords::Virtualizer.new(
        :for_subclasses_of =>  [ActiveRecord::Base, ApplicationController]
    )
  end 

  it 'virtualizes "if" on instances' do
    @virtualizer.virtual_if do |condition, then_do, else_do|
      :clobbered_if 
    end
    result = @greeter.greet_if_else
    result.should eql :clobbered_if
  end

  it 'virtualizes "and" on instances' do
    @virtualizer.virtual_and do |first, second|
      first.call or second.call
    end
    @my_class.foo.should eql :tampered_and
  end

  it 'virtualizes "or" on instances' do
    @virtualizer.virtual_or do |first, second|
      first.call and second.call
    end
    @my_class.bar.should eql :tampered_or
  end

  it 'virtualizes "if" on classes' do
    @class_virtualizer.virtual_if do |condition, then_do, else_do|
      if not condition.call   
        then_do.call
      else
        else_do.call
      end
    end  

    @another_class.quux.should eql :if_modified
  end

  it 'virtualizes "if" on subclasses of given classes' do
    @subclass_virtualizer.virtual_if do |condition, then_do, else_do|
      if not condition.call   
        then_do.call
      else
        else_do.call
      end
    end  

    # AnotherClass shouldn't be modified, it's not a subclass of itself
    @another_class.quux.should eql :right
    @yet_another_class.quux.should eql :if_modified
  end

  it 'virtualizes "while" on instances' do
    @virtualizer.virtual_while do |condition, body|
      # call the body once, regardless of condition
      body.call      
    end

    result = @while_counter.run
    result.should eql [0]
  end

  it 'virtualizes "until" on instances' do
    @virtualizer.virtual_until do |condition, body|
      # flip it into a while
      while condition.call
        body.call
      end
    end
    
    result = @until_counter.run
    result.should eql []
  end

  it 'virtualizes "not" on instances' do
    @virtualizer.virtual_not do |value|
      value.call
    end

    result = @inverter.run true
    result.should be_true
  end

  it 'virtualizes multiple keywords in the same method' do
    if_calls = 0
    and_calls = 0
    @virtualizer.virtual_if do |condition, then_do, else_do|
      if_calls += 1
      if condition.call then then_do.call else else_do.call end
    end
    @virtualizer.virtual_and do |first, second|
      and_calls += 1
      first.call and second.call
    end
    @my_class.foo
    if_calls.should eql 1
    and_calls.should eql 1
  end
end
