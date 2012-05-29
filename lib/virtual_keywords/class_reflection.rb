module VirtualKeywords
  # Utility functions used to inspect the class hierarchy, and to view
  # and modify methods of classes.
  class ClassReflection
    # Get the subclasses of a given class.
    #
    # Arguments:
    #   parent: (Class) the class whose subclasses to find.
    #
    # Returns:
    #   (Array) all classes which are subclasses of parent.
    def subclasses_of_class(parent)
      ObjectSpace.each_object(Class).select { |klass|
        klass < parent
      }
    end

    # Given an array of base classes, return a flat array of all their
    # subclasses.
    #
    # Arguments:
    #   klasses: (Array[Class]) an array of classes
    #
    # Returns:
    #   (Array) All classes that are subclasses of one of the classes in klasses,
    #           in a flattened array.
    def subclasses_of_classes(klasses)
      klasses.map { |klass|
        subclasses_of_class klass
      }.flatten
    end

    # Get the instance_methods of a class.
    #
    # Arguments:
    #   klass: (Class) the class.
    #
    # Returns:
    #   (Hash[Symbol, Array]) A hash, mapping method names to the results of
    #                         ParseTree.translate.
    def instance_methods_of(klass)
      methods = {}
      klass.instance_methods(false).each do |method_name|
        translated = ParseTree.translate(klass, method_name)
        methods[method_name] = translated
      end

      methods
    end

    # Install a method on a class. When object.method_name is called
    # (for objects in the class), have them run the given code.
    # TODO Should it be possible to recover the old method?
    # How would that API look?
    #
    # Arguments:
    #   klass: (Class) the class which should be modified.
    #   method_code: (String) the code for the method to install, of the format:
    #       def method_name(args)
    #         ...
    #       end
    def install_method_on_class(klass, method_code)
      klass.class_eval method_code
    end

    # Install a method on an object. When object.method_name is called,
    # runs the given code.
    #
    # This function can also be used for classmethods. For example, if you want
    # to rewrite Klass.method_name (a method on Klass, a singleton Class),
    # call this method (NOT install_method_on_class, that will modifiy objects
    # created through Klass.new!)
    #
    # Arguments:
    #   object: (Object) the object instance that should be modified.
    #   method_code: (String) the code for the method to install, of the format:
    #       def method_name(args)
    #         ...
    #       end
    def install_method_on_instance(object, method_code)
      object.instance_eval method_code
    end
  end
end
