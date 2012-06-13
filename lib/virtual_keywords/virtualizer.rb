# Parent module containing all variables defined as part of virtual_keywords
module VirtualKeywords

  class NoSuchInstance < StandardError
  end

  class NoSuchClass < StandardError
  end

  # Object that virtualizes keywords.
  class Virtualizer
    # Initialize a Virtualizer
    # 
    # Arguments:
    #   A Hash with the following key-value pairs (all optional):
    #   for_classes: (Array[Class]) an array of classes. All methods of objects
    #       created from the given classes will be virtualized (optional, the
    #       default is an empty Array).
    #   for_instances: (Array[Object]) an array of object. All of these objects'
    #       methods will be virtualized
    #       (optional, the default is an empty Array).
    #   for subclasses_of: (Array[Class]) an array of classes. All methods of
    #       objects created from the given classes' subclasses (but NOT those
    #       from the given classes) will be virtualized.
    #   if_rewriter: (IfRewriter) the SexpProcessor descendant that
    #       rewrites "if"s in methods (optional, the default is
    #       IfRewriter.new).
    #   and_rewriter: (AndRewriter) the SexpProcessor descendant that
    #       rewrites "and"s in methods (optional, the default is
    #       AndRewriter.new).
    #   or_rewriter: (OrRewriter) the SexpProcessor descendant that
    #       rewrites "or"s in methods (optional, the default is
    #       OrRewriter.new).
    #   not_rewriter: (NotRewriter) the SexpProcessor descendant that
    #       rewrites "not"s in methods (optional, the default is
    #       NotRewriter.new).
    #   while_rewriter: (WhileRewriter) the SexpProcessor descendant that
    #       rewrites "while"s in methods (optional, the default is
    #       WhileRewriter.new).
    #   until_rewriter: (UntilRewriter) the SexpProcessor descendant that
    #       rewrites "until"s in methods (optional, the default is
    #       UntilRewriter.new).
    #   sexp_stringifier: (SexpStringifier) an object that can turn sexps
    #       back into Ruby code (optional, the default is
    #       SexpStringifier.new).
    #   rewritten_keywords: (RewrittenKeywords) a repository for keyword
    #       replacement lambdas (optional, the default is REWRITTEN_KEYWORDS).
    #   class_reflection: (Class) an object that provides methods to modify the
    #       methods of classes (optional, the default is ClassReflection).
    def initialize(input_hash)
      @for_classes = input_hash[:for_classes] || []
      @for_instances = input_hash[:for_instances] || []
      @for_subclasses_of = input_hash[:for_subclasses_of] || []
      @if_rewriter = input_hash[:if_rewriter] || IfRewriter.new
      @and_rewriter = input_hash[:and_rewriter] || AndRewriter.new
      @or_rewriter = input_hash[:or_rewriter] || OrRewriter.new
      @not_rewriter = input_hash[:or_rewriter] || NotRewriter.new
      @while_rewriter = input_hash[:while_rewriter] || WhileRewriter.new
      @until_rewriter = input_hash[:until_rewriter] || UntilRewriter.new
      @sexp_stringifier = input_hash[:sexp_stringifier] || SexpStringifier.new
      @rewritten_keywords =
          input_hash[:rewritten_keywords] || REWRITTEN_KEYWORDS
      @class_reflection = input_hash[:class_reflection] || ClassReflection.new
      @class_mirrorer = input_hash[:class_mirrorer] || ClassMirrorer.new({})

      @sexps_for_classes = {}
      @sexps_for_instances = {}
      # TODO Refactor out work in the constructor
      # and maybe move the sexp storage elsewhere.
      parse_all_the_classes
    end

    def parse_all_the_classes
      # Well, not _all_, just the ones provided in the constructor..
      @for_classes.each do |klass|
        @sexps_for_classes[klass] = @class_mirrorer.mirror klass
      end
      @for_instances.each do |instance|
        @sexps_for_instances[instance] = @class_mirrorer.mirror instance.class
      end
      @for_subclasses_of.each do |klass|
        subclasses = @class_reflection.subclasses_of_class klass
        subclasses.each do |subclass|
          @sexps_for_classes[subclass] = @class_mirrorer.mirror subclass
        end
      end
    end

    def rewritten_sexp(sexp, rewriter)
      sexp_copy = VirtualKeywords.deep_copy_array sexp
      rewriter.process sexp_copy 
    end

    # Helper method to rewrite code.
    #
    # Arguments:
    #   translated: (Sexp) the sexp for code
    #   rewriter: (SexpProcessor) the object that will rewrite the sexp, to
    #       virtualize the keywords.
    def rewritten_code(sexp, rewriter)
      sexp_copy = VirtualKeywords.deep_copy_array sexp
      new_code = @sexp_stringifier.stringify(
          rewriter.process(sexp_copy))
    end

    # Helper method to rewrite all methods of an object.
    #
    # Arguments:
    #   instance: (Object) the object whose methods will be rewritten.
    #   keyword: (Symbol) the keyword to virtualize.
    #   rewriter: (SexpProcessor) the object that will do the rewriting.
    #   block: (Proc) the lambda that will replace the keyword.
    def rewrite_all_methods_of_instance(instance, keyword, rewriter, block)
      @rewritten_keywords.register_lambda_for_object(instance, keyword, block)

      if not @sexps_for_instances.include? instance
        raise NoSuchInstance, "Tried to rewrite methods of #{instance}," +
            "but it's not there!"
      end
      mirror_hash = @sexps_for_instances[instance]
      new_mirror_hash = {}
      mirror_hash.each do |class_and_method_name, sexp|
        new_sexp = rewritten_sexp(sexp, rewriter)
        new_code = @sexp_stringifier.stringify new_sexp
        @class_reflection.install_method_on_instance(instance, new_code)
        # Save the modified sexp for the next go
        new_mirror_hash[class_and_method_name] = new_sexp
      end
      @sexps_for_instances[instance] = new_mirror_hash
    end

    # Helper method to rewrite all methods of objects from a class.
    #
    # Arguments:
    #   klass: (Class) the class whose methods will be rewritten.
    #   keyword: (Symbol) the keyword to virtualize.
    #   rewriter: (SexpProcessor) the object that will do the rewriting.
    #   block: (Proc) the lambda that will replace the keyword.
    def rewrite_all_methods_of_class(klass, keyword, rewriter, block)
      @rewritten_keywords.register_lambda_for_class(klass, keyword, block)

      if not @sexps_for_classes.include? klass
        raise NoSuchInstance, "Tried to rewrite methods of #{klass}," +
            "but it's not there!"
      end
      mirror_hash = @sexps_for_classes[klass]
      new_mirror_hash = {}
      mirror_hash.each do |class_and_method_name, sexp|
        new_sexp = rewritten_sexp(sexp, rewriter)
        new_code = @sexp_stringifier.stringify new_sexp
        @class_reflection.install_method_on_class(klass, new_code)
        new_mirror_hash[class_and_method_name] = new_sexp
      end
      @sexps_for_classes[klass] = new_mirror_hash
    end

    # Helper method to virtualize a keyword (rewrite with the given block)
    #
    # Arguments:
    #   keyword: (Symbol) the keyword to virtualize.
    #   rewriter: (SexpProcessor) the object that will do the rewriting.
    #   block: (Proc) the lambda that will replace the keyword.
    def virtualize_keyword(keyword, rewriter, block)
      @for_instances.each do |instance|
        rewrite_all_methods_of_instance(instance, keyword, rewriter, block)  
      end 

      @for_classes.each do |klass|
        rewrite_all_methods_of_class(klass, keyword, rewriter, block)
      end

      subclasses = @class_reflection.subclasses_of_classes @for_subclasses_of
      subclasses.each do |subclass|
        rewrite_all_methods_of_class(subclass, keyword, rewriter, block)
      end
    end

    # Rewrite "if" expressions.
    #
    # Arguments:
    #   &block: The block that will replace "if"s in the objects being
    #       virtualized
    def virtual_if(&block)
      virtualize_keyword(:if, @if_rewriter, block)
    end

    # Rewrite "and" expressions.
    #
    # Arguments:
    #   &block: The block that will replace "and"s in the objects being
    #       virtualized
    def virtual_and(&block)
      virtualize_keyword(:and, @and_rewriter, block)
    end

    # Rewrite "or" expressions.
    #
    # Arguments:
    #   &block: The block that will replace "or"s in the objects being
    #       virtualized
    def virtual_or(&block)
      virtualize_keyword(:or, @or_rewriter, block)
    end

    # Rewrite "not" expressions.
    #
    # Arguments:
    #   &block: The block that will replace "not"s in the objects being
    #       virtualized
    def virtual_not(&block)
      virtualize_keyword(:not, @not_rewriter, block)
    end

    # Rewrite "while" expressions.
    #
    # Arguments:
    #   &block: The block that will replace "while"s in the objects being
    #       virtualized
    def virtual_while(&block)
      virtualize_keyword(:while, @while_rewriter, block)
    end

    # Rewrite "until" expressions.
    #
    # Arguments:
    #   &block: The block that will replace "until"s in the objects being
    #       virtualized
    def virtual_until(&block)
      virtualize_keyword(:until, @until_rewriter, block)
    end
  end
end
