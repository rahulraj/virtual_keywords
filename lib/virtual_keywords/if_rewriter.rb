#!/usr/bin/env ruby
# I'm using Ruby 1.8.7

module VirtualKeywords

  # Get the descendant classes of a given class
  #
  # Arguments:
  #   parent: (Class) the class whose descendants to find.
  #
  # Returns:
  #   (Array) all classes which are subclasses of parent.
  def descendants_of(parent)
    ObjectSpace.each_object(Class).select { |klass|
      klass < parent
    }
  end

  # Given an array of base classes, return a flat array of all their subclasses
  def subclasses_of(klasses)
    klasses.map { |klass|
      descendants_of klass
    }.flatten
  end

  # Get the instance_methods of a class
  # Returns: A hash, mapping method names to results of ParseTree.translate
  # (ParseTree.translate outputs a nested Array)
  def instance_methods_of(klass)
    methods = {}
    klass.instance_methods.each do |method_name|
      translated = ParseTree.translate(klass, method_name)
      methods[method_name] = translated
    end

    methods
  end

  # Deeply copy an array
  # There's got to be a better way...
  def deep_copy_array(array)
    Marshal.load(Marshal.dump(array))
  end

  def install_method(klass, method_name, code)
    klass.class_eval do
      define_method(method_name) do
        self.instance_eval code
      end
    end
  end

  class Virtualizer
    def initialize(keyword_rewriter, sexp_processor)
      @keyword_rewriter = keyword_rewriter
      @sexp_processor = sexp_processor
    end

    def rewrite_keywords_on(klass)
      old_methods = instance_methods_of klass  
      old_methods.each do |name, translated|
        sexp = sexp_processor.process(deep_copy_array(translated))
        rewritten_sexp = @keyword_rewriter.process sexp

        install_method(klass, name, sexp_to_string(rewritten_sexp)) 
      end
    end
  end


  def main
    include Aquarium::Aspects
    rails_classes = [ActiveRecord::Base, ApplicationController]
    to_intercept = subclasses_of rails_classes
    processor = SexpProcessor.new
    if_rewriter = IfProcessor.new 
    mirrorer = new_class_mirrorer

    # Aquarium changes the methods to advise them, so save them beforehand
    mirrored_methods = mirrorer.call to_intercept

    # Some thoughts on interception
    # Removing method_options segfaults
    # Changing Fizzbuzzer to Object causes it to not intercept Fizzbuzzer methods
    # (so it's not covariant)
    Aspect.new :around, :calls_to => :all_methods, :for_types => to_intercept,
        :method_options => :exclude_ancestor_methods do |join_point, obj, *args|
      begin
        p "Entering: #{join_point.target_type.name}##{join_point.method_name}: args = #{args.inspect}"

        method_name = join_point.method_name.to_s

        # Save the Aquarium-modified method, we'll need it later
        modified_method = ParseTree.translate(obj.class, method_name)

        key = ClassAndMethodName.new(obj.class, method_name)
        translated = mirrored_methods[key]

        # GOTCHA: SexpProcessor#process turns its argument into an empty array
        # We need to copy arrays before feeding it to this method if we want
        # to keep them around.
        # This is supposed to be "process", not "process_and_eat_your_array"...
        sexp = processor.process(deep_copy_array(translated))

        # Do stuff with sexp...
        rewritten_sexp = if_rewriter.process sexp

        code_again = sexp_to_string rewritten_sexp

        # Uncomment this if you want to check that it IS processing the code.
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

    greeter = Greeter.new(true)
    puts greeter.greet
  end
end

# Run main() only if if_rewriter is executed with the ruby command, not
# imported. Like "if __name__ == '__main__': " in Python
if __FILE__ == $0
  VirtualKeywords::main()
end
