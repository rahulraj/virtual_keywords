require 'spec_helper'

describe 'if_rewriter' do

  it 'Retrieves the instance methods of a class' do
    method_names = instance_methods_of(Fizzbuzzer).keys
    method_names.should include 'fizzbuzz'
  end

  it 'Finds the subclasses of classes and flattens the result' do
    rails_classes = [ActiveRecord::Base, ApplicationController]
    subclasses = subclasses_of rails_classes

    subclasses.should include Fizzbuzzer
    subclasses.should include Greeter
  end

end
