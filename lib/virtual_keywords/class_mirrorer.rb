module VirtualKeywords
  # Simple data object holding a Class and the name of one of its methods
  ClassAndMethodName = Struct.new(:klass, :method_name)

  # Class that takes classes and "mirrors" them, by parsing their methods
  # and storing the results.
  class ClassMirrorer
    # Initialize a ClassMirrorer
    #
    # Arguments:
    #   parser: (Class) an object with a method translate, that takes a class
    #           and method name, and returns a syntax tree that can be
    #           sexpified (optional, uses ParseTree by default).
    def initialize(parser = ParseTree)
      @parser = parser
    end

    # Map ClassAndMethodNames to outputs of parser.translate
    #
    # Arguments:
    #   klasses: (Array[Class]) the classes to mirror.
    #
    # Returns:
    #   (Hash[ClassAndMethodName, Array]) a hash mapping every method of every
    #   class to parsed output.
    def mirror(klasses)
      methods = {}
      klasses.each do |klass|
        klass.instance_methods.each do |method_name|
          key = ClassAndMethodName.new(klass, method_name)
          translated = @parser.translate(klass, method_name)
          methods[key] = translated
        end 
      end

      methods
    end
  end
end
