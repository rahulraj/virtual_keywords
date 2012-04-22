require 'spec_helper'

include VirtualKeywords::ClassReflection

describe 'instance_methods_of' do
  it 'retrieves the instance methods of a class' do
    method_names = instance_methods_of(Fizzbuzzer).keys
    method_names.should include 'fizzbuzz'
  end
end

describe 'subclasses_of_classes' do
  it 'finds the subclasses of classes and flattens the result' do
    rails_classes = [ActiveRecord::Base, ApplicationController]
    subclasses = subclasses_of_classes rails_classes

    subclasses.should include Fizzbuzzer
    subclasses.should include Greeter
  end
end

describe 'install_method_on_class' do
  before :each do
    class MyClass
      def foo
        :hello
      end
    end
    @object = MyClass.new
  end
  
  it 'installs methods on classes' do
    install_method_on_class(MyClass, 'def foo; :goodbye; end')
    @object.foo.should eql :goodbye
  end

  it 'installs methods that change instance fields' do
    class MyClass
      def foo
        :hello
      end
    end
    install_method_on_class(MyClass, 'def foo; @bar = :bar; :goodbye; end')
    install_method_on_class(MyClass, 'def bar; @bar; end')

    @object.foo.should eql :goodbye
    @object.bar.should eql :bar
  end

  it 'installs methods that mutate globals' do
    $thing = :old
    install_method_on_class(MyClass, 'def foo; $thing = :new; end')
    
    @object.foo()
    $thing.should eql :new
  end
end

describe 'install_method_on_instance' do
  before :each do
    class MyClass
      def foo
        :hello
      end
    end
    @object1 = MyClass.new
    @object2 = MyClass.new
  end

  it 'installs methods on specific instances' do
    install_method_on_instance(@object1, 'def foo; :goodbye; end')
    @object1.foo.should eql :goodbye
    @object2.foo.should eql :hello
  end
end

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

    @my_class = MyClass.new
    @another_class = AnotherClass.new
    @yet_another_class = YetAnotherClass.new
    @virtualizer = VirtualKeywords::Virtualizer.new(
        :for_instances => [@greeter, @my_class]
    )
    @class_virtualizer = VirtualKeywords::Virtualizer.new(
        :for_classes => [AnotherClass]
    )
    @subclass_virtualizer = VirtualKeywords::Virtualizer.new(
        :for_subclasses_of => [AnotherClass]
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
    
    @another_class.quux.should eql :right
    @yet_another_class.quux.should eql :if_modified
  end
end
