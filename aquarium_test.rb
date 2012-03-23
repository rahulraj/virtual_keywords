#!/usr/bin/env ruby
# I'm using Ruby 1.8.7
require 'rubygems'
require 'bundler/setup'

require './fizzbuzz'
# Don't intercept the library classes' methods
# At the very least, we can't intercept aquarium methods, that will
# cause infinite recursion
# This bit still needs work
#all_classes = ObjectSpace.each_object(Class).to_a

require 'parse_tree'
require 'ruby2ruby'
require 'aquarium'


include Aquarium::Aspects

processor = SexpProcessor.new

def instance_methods_of(klass)
  # Get the instance_methods of a class
  # Returns: A hash, mapping method names to results of ParseTree.translate
  # (ParseTree.translate outputs a nested Array)
  methods = {}
  klass.instance_methods.each do |method_name|
    translated = ParseTree.translate(klass, method_name)
    methods[method_name] = translated
  end

  methods
end

def sexp_to_string(sexp)
  # Turn a sexp into a string of Ruby code
  unifier = Unifier.new
  ruby2ruby = Ruby2Ruby.new
  unified = unifier.process sexp
  
  ruby2ruby.process unified
end

def deep_copy_of_array(array)
  # There's got to be a better way...
  Marshal.load(Marshal.dump(array))
end

# Aquarium changes the methods to advise them, so save them beforehand
fizzbuzzer_instance_methods = instance_methods_of Fizzbuzzer

# Some thoughts on interception
# Removing method_options segfaults
# Changing Fizzbuzzer to Object causes it to not intercept Fizzbuzzer methods
# (so it's not covariant)

#Aspect.new :around, :calls_to => :all_methods, :for_types => /$/,
#Aspect.new :around, :calls_to => :all_methods, :for_types => all_classes,
# Nope, too broad..

Aspect.new :around, :calls_to => :all_methods, :for_types => [Fizzbuzzer],
    :method_options => :exclude_ancestor_methods do |join_point, obj, *args|
  begin
    p "Entering: #{join_point.target_type.name}##{join_point.method_name}: args = #{args.inspect}"

    method_name = join_point.method_name.to_s

    # Save the Aquarium-modified method, we'll need it later
    modified_method = ParseTree.translate(obj.class, method_name)

    translated = fizzbuzzer_instance_methods[method_name]


    # GOTCHA: SexpProcessor#process turns its argument into an empty array
    # We need to copy arrays before feeding it to this method if we want
    # to keep them around.
    # This is supposed to be "process", not "process_and_eat_your_array"...
    sexp = processor.process(deep_copy_of_array(translated))

    # Do stuff with sexp...

    code_again = sexp_to_string sexp

    # Uncomment this if you want to check that it IS getting the code.
    #puts code_again 


    
    # We need to "install" the modified method into the object
    # This works, but clobbers the advice, so future calls don't get intercepted
    obj.instance_eval code_again
    # Then do this instead of join_point.proceed.
    # Don't forget to save the result!
    result = obj.send(method_name, *args)

    # But this issue is fixable. Put the Aquarium method back in.
    modified_sexp = processor.process modified_method
    modified_code = sexp_to_string modified_sexp
    obj.instance_eval modified_code

    # Finally, send the result of the method call through
    result
  ensure
    p "Leaving:  #{join_point.target_type.name}##{join_point.method_name}: args = #{args.inspect}"
  end
end

# All of the method calls on this object should be intercepted
fizzbuzzer = Fizzbuzzer.new
puts "fizzbuzz(5) is #{fizzbuzzer.fizzbuzz 5}"

puts "fizzbuzz(9) is #{fizzbuzzer.fizzbuzz 9}"

fizzbuzzer.greet
