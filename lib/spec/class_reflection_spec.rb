require 'spec_helper'

describe 'ClassReflection' do
  before :each do
    class MyClass
      def foo
        :hello
      end
    end
    @object = MyClass.new
    @object2 = MyClass.new

    @reflection = VirtualKeywords::ClassReflection.new
  end

  it 'retrieves the instance methods of a class' do
    method_names = @reflection.instance_methods_of(Fizzbuzzer).keys
    method_names.should include :fizzbuzz
  end

  it 'finds the subclasses of classes and flattens the result' do
    rails_classes = [ActiveRecord::Base, ApplicationController]
    subclasses = @reflection.subclasses_of_classes rails_classes

    subclasses.should include Fizzbuzzer
    subclasses.should include Greeter
  end

  it 'installs methods on classes' do
    @reflection.install_method_on_class(MyClass, 'def foo; :goodbye; end')
    @object.foo.should eql :goodbye
  end

  it 'installs methods that change instance fields' do
    class MyClass
      def foo
        :hello
      end
    end
    @reflection.install_method_on_class(
        MyClass, 'def foo; @bar = :bar; :goodbye; end')
    @reflection.install_method_on_class(
        MyClass, 'def bar; @bar; end')

    @object.foo.should eql :goodbye
    @object.bar.should eql :bar
  end

  it 'installs methods that mutate globals' do
    $thing = :old
    @reflection.install_method_on_class(
        MyClass, 'def foo; $thing = :new; end')
    
    @object.foo
    $thing.should eql :new
  end

  it 'installs methods on specific instances' do
    @reflection.install_method_on_instance(
        @object, 'def foo; :goodbye; end')
    @object.foo.should eql :goodbye
    @object2.foo.should eql :hello
  end
end
