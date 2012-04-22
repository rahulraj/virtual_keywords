module VirtualKeywords

  # Simple data object holding an object and a Ruby keyword (as a symbol)
  ObjectAndKeyword = Struct.new(:object, :keyword)

  # Exception raised when a client tries to call the rewritten version of a
  # keyword, but no lambda was provided for the given object and keyword.
  class RewriteLambdaNotProvided < StandardError
  end

  # Class holding the lambdas to call in place of keywords.
  # Different classes can have their own set of "virtualized keywords".
  class RewrittenKeywords

    # Initialize a RewrittenKeywords
    #
    # Arguments:
    #   objects_to_blocks: (Hash[ObjectAndKeyword, Proc]) a hash mapping
    #                      ObjectAndKeyword objects to the lambdas that should
    #                      be called in place of the keyword in the object's
    #                      methods (optional, an empty Hash is the default).
    def initialize(objects_to_blocks = {})
      @objects_to_blocks = objects_to_blocks
    end

    # Register (save) a lambda to be called for an object.
    #
    # Arguments:
    #   object_and_keyword: (ObjectAndKeyword) The data structure holding the
    #                       object and keyword in question. In all methods of
    #                       the object, the keyword will be replaced by the
    #                       lambda.
    #   a_lambda: (Proc) The lambda to be called in place of the keyword.
    def register_lambda(object_and_keyword, a_lambda)
      @objects_to_blocks[object_and_keyword] = a_lambda
    end

    # Get the key in objects_to_blocks for the given input, or raise an
    # exception if it's not there.
    #
    # Arguments:
    #   caller_object: (Object) the object part of the ObjectAndKeyword
    #   keyword: (Symbol) they keyword part of the ObjectAndKeyword
    #
    # Raises:
    #   RewriteLambdaNotProvided if the ObjectAndKeyword is not in
    #   @objects_to_blocks
    def key_or_raise(caller_object, keyword)
      key = ObjectAndKeyword.new(caller_object, keyword)
      if not @objects_to_blocks.include? key
        raise RewriteLambdaNotProvided, 'A rewrite was requested for ' +
            "#{caller_object}'s #{keyword} expressions, but there's no" +
            'lambda for it.'
      end

      key
    end

    # Call an if virtual block in place of an actual if expression.
    # This function locates the lambda registered with the given object.
    #
    # Arguments:
    #   caller_object: (Object) the object whose method this is being called in.
    #   condition: (Proc) The condition of the if statement, wrapped in a
    #              lambda.
    #   then_do: (Proc) the lambda to execute if the condition is true (but
    #            the user-supplied block may do something else)
    #   else_do: (Proc) the lambda to execute if the condition is false (but
    #            the user-supplied block may do something else)
    #
    # Raises:
    #   RewriteLambdaNotProvided if no "if" lambda is available.
    def call_if(caller_object, condition, then_do, else_do)
      key = key_or_raise(caller_object, :if)
      @objects_to_blocks[key].call(condition, then_do, else_do)
    end

    # Call an "and" virtual block in place of an "and" expression.
    #
    # Arguments:
    #   caller_object: (Object) the object whose method this is being called in.
    #   first: (Proc) The first operand of the "and", wrapped in a lambda.   
    #   second: (Proc) The second operand of the "and", wrapped in a lambda.   
    #   
    # Raises:
    #   RewriteLambdaNotProvided if no "and" lambda is available.
    def call_and(caller_object, first, second)
      key = key_or_raise(caller_object, :and)
      @objects_to_blocks[key].call(first, second)
    end

    # Call an "or" virtual block in place of an "or" expression.
    #
    # Arguments:
    #   caller_object: (Object) the object whose method this is being called in.
    #   first: (Proc) The first operand of the "or", wrapped in a lambda.   
    #   second: (Proc) The second operand of the "or", wrapped in a lambda.   
    #   
    # Raises:
    #   RewriteLambdaNotProvided if no "or" lambda is available.
    def call_or(caller_object, first, second)
      key = key_or_raise(caller_object, :or)
      @objects_to_blocks[key].call(first, second)
    end
  end


  # The global instance of RewrittenKeywords that will be used.
  # I don't normally like using global variables, but in this case
  # we need a global point of access, because we can't always control the
  # scope in which methods are executed.
  REWRITTEN_KEYWORDS = RewrittenKeywords.new
end
