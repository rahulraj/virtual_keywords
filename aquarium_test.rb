#!/usr/bin/env ruby
# Example demonstrating "around" advice that traces calls to all methods in
# classes Foo and Bar
require 'rubygems'
require 'bundler/setup'

#$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'parse_tree'
require 'ruby2ruby'

require 'aquarium'
require './fizzbuzz'


include Aquarium::Aspects

processor = SexpProcessor.new

def instance_methods_of(klass)
  methods = {}
  klass.instance_methods.each do |method_name|
    translated = ParseTree.translate(klass, method_name)
    methods[method_name] = translated
  end

  methods
end

def sexp_to_string(sexp)
  unifier = Unifier.new
  ruby2ruby = Ruby2Ruby.new
  unified = unifier.process sexp
  
  ruby2ruby.process unified
end

def deep_copy_of_array(array)
  # There's got to be a better way...
  Marshal.load(Marshal.dump(array))
end

#def advice_class(klass, block)
  #Aspect.new :around, :calls_to => :all_methods, :for_types => [klass],
      #:method_options => :exclude_ancestor_methods do |join_point, obj, *args|
    #block.call(join_point, obj, *args)
  #end
#end

# Aquarium changes the methods to advise them, so save them beforehand
fizzbuzzer_instance_methods = instance_methods_of Fizzbuzzer

#intercept_and_translate = lambda { |join_point, obj, *args|
  #begin
    #p "Entering: #{join_point.target_type.name}##{join_point.method_name}: args = #{args.inspect}"
    #method_name = join_point.method_name.to_s
    #translated = fizzbuzzer_instance_methods[method_name]
    #p translated

    #puts ""
    #sexp = processor.process translated
    #p sexp

    ## Do stuff with sexp...

    #puts ""
    #code_again = sexp_to_string sexp
    #puts code_again


    ##join_point.proceed
    
    ## Works, but clobbers the advice, so future calls don't work
    #obj.instance_eval code_again
    #obj.send(method_name, *args)

    ## Then readvise the object
    #advice_class(obj.class, intercept_and_translate)
  #ensure
    #p "Leaving:  #{join_point.target_type.name}##{join_point.method_name}: args = #{args.inspect}"
  #end
#}

# Removing method_options segfaults
# Changing Fizzbuzzer to Object causes it to not intercept the methods
# (so it's not covariant)
Aspect.new :around, :calls_to => :all_methods, :for_types => [Fizzbuzzer],
    :method_options => :exclude_ancestor_methods do |join_point, obj, *args|
  begin
    p "Entering: #{join_point.target_type.name}##{join_point.method_name}: args = #{args.inspect}"

    method_name = join_point.method_name.to_s

    # Save the Aquarium-modified method, we'll need it later
    modified_method = ParseTree.translate(obj.class, method_name)
    #puts "modified_method #{modified_method}"

    translated = fizzbuzzer_instance_methods[method_name]
    #puts "translated:"
    #p translated


    #puts ""
    # GOTCHA: SexpProcessor#process turns its argument into an empty array
    # We need to copy arrays before feeding it to this method if we want
    # to keep them around.
    # This is supposed to be "process", not "process_and_eat_your_array"...
    sexp = processor.process(deep_copy_of_array(translated))
    #p sexp

    # Do stuff with sexp...

    #puts ""
    code_again = sexp_to_string sexp
    puts code_again


    #join_point.proceed
    
    # Works, but clobbers the advice, so future calls don't work
    obj.instance_eval code_again
    obj.send(method_name, *args)


    # Then put the Aquarium method back
    modified_sexp = processor.process modified_method
    modified_code = sexp_to_string modified_sexp
    obj.instance_eval modified_code
  ensure
    p "Leaving:  #{join_point.target_type.name}##{join_point.method_name}: args = #{args.inspect}"
  end
end

#advice_class(Fizzbuzzer, intercept_and_translate)
fizzbuzzer = Fizzbuzzer.new
puts fizzbuzzer.fizzbuzz(5)

puts "In between calls"
puts "fizzbuzz"
p fizzbuzzer_instance_methods['fizzbuzz']
puts "\n--------------------\n"

puts fizzbuzzer.fizzbuzz(9)
# TODO Reread the Aquarium docs, figure out how to calibrate these methods
