r:qequire 'rubygems'
require 'bundler/setup'

require 'fizzbuzz'

require 'sourcify'
require 'aquarium'


include Aquarium::Aspects
Aspect.new :before, :calls_to => :all_methods,
    :on_types => [Fizzbuzz::Fizzbuzzer] do |join_point, object, *arguments|
  puts "calling #{join_point.inspect}"
end

fizzbuzzer = Fizzbuzz::Fizzbuzzer.new
puts fizzbuzzer.fizzbuzz(1)

#describe 'fizzbuzz' do
  #it 'outputs the number if not divisible by 3 or 5' do

    #include Aquarium::DSL
    #before :calls_to => :all_methods do |join_point, object, *args|
      #puts "Entering #{join_point.target_type.name}#" +
        #"#{join_point.method_name}: object = #{object}, args = #{args}"
    #end

    #result = fizzbuzz 1
    #result.first.should eq '1'
  #end
#end
