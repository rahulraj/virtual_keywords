require 'spec_helper'

describe 'if_rewriter' do
  it 'retrieves the instance methods of a class' do
    method_names = instance_methods_of(Fizzbuzzer).keys
    method_names.should include 'fizzbuzz'
  end

  it 'finds the subclasses of classes and flattens the result' do
    rails_classes = [ActiveRecord::Base, ApplicationController]
    subclasses = subclasses_of rails_classes

    subclasses.should include Fizzbuzzer
    subclasses.should include Greeter
  end
end

describe 'install_method' do
  before :each do
    class MyClass
      def foo
        :hello
      end
    end
    @object = MyClass.new
  end
  
  it 'installs methods on classes' do
    install_method(MyClass, :foo, ':goodbye')
    @object.foo.should eql :goodbye
  end

  it 'installs methods that change instance fields' do
    class MyClass
      def foo
        :hello
      end
    end
    install_method(MyClass, :foo, '@bar = :bar; :goodbye')
    install_method(MyClass, :bar, '@bar')

    @object.foo.should eql :goodbye
    @object.bar.should eql :bar
  end

  it 'installs methods that mutate globals' do
    $thing = :old
    install_method(MyClass, :foo, '$thing = :new')
    
    @object.foo()
    $thing.should eql :new
  end
end
