module VirtualKeywords
  # Simple data object holding a Class and the name of one of its methods
  ClassAndMethodName = Struct.new(:klass, :method_name)

  # ClassMirrorer that uses ParseTree (Ruby 1.8)
  class ClassMirrorer
    # Initialize a ParseTreeClassMirrorer
    #
    # Arguments:
    #   An options Hash with the following key
    #     parser: (ParserStrategy) an object with a method translate, that takes
    #         a class and method name, and returns a syntax tree that can be
    #         sexpified (optional, the default is ParserStrategy.new)
    def initialize options
      @parser = options[:parser] || ParserStrategy.new
    end

    # Map ClassAndMethodNames to sexps
    #
    # Arguments:
    #   klass: (Class) the class to mirror.
    #
    # Returns:
    #   (Hash[ClassAndMethodName, Sexp]) a hash mapping every method of the
    #   class to parsed output.
    def mirror klass
      methods = {}
      klass.instance_methods(false).each do |method_name|
        key = ClassAndMethodName.new(klass, method_name)
        translated = @parser.translate_instance_method(klass, method_name)
        methods[key] = translated
      end

      methods
    end
  end
end
