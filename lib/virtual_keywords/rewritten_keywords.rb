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
    #   A Hash with the following key:
    #   predicates_to_blocks: (Hash[Proc, Proc]) a hash mapping predicates that
    #                         take ObjectAndKeywords and return true for matches
    #                         to the lambdas that should be called in place of
    #                         the keyword in the object's methods
    #                         (optional, an empty Hash is the default).
    def initialize(input)
      @predicates_to_blocks = input[:predicates_to_blocks] || {}
    end

    # Register (save) a lambda to be called for a specific object.
    #
    # Arguments:
    #   object: (Object) the object whose methods will have their keyword
    #           virtualized.
    #   keyword: (Symbol) the keyword that will be virtualized
    #   a_lambda: (Proc) The lambda to be called in place of the keyword.
    def register_lambda_for_object(object, keyword, a_lambda)
      predicate = lambda { |input|
        input.object == object and input.keyword == keyword
      }
      @predicates_to_blocks[predicate] = a_lambda
    end

    def register_lambda_for_class(klass, keyword, a_lambda)
      predicate = lambda { |input|
        input.object.is_a?(klass) and input.keyword == keyword
      }
      @predicates_to_blocks[predicate] = a_lambda
    end

    # Get the virtual lambda to call for the given input, or raise an
    # exception if it's not there.
    #
    # Arguments:
    #   caller_object: (Object) the object part of the ObjectAndKeyword
    #   keyword: (Symbol) they keyword part of the ObjectAndKeyword
    #
    # Returns:
    #   The lambda to call for that object's keyword, if the object and keyword
    #   matched any of the predicates.
    #
    # Raises:
    #   RewriteLambdaNotProvided if no predicate returns true for
    #   ObjectAndKeyword.
    def lambda_or_raise(caller_object, keyword)
      object_and_keyword = ObjectAndKeyword.new(caller_object, keyword)
      matching = @predicates_to_blocks.keys.find { |predicate|
        predicate.call(object_and_keyword)
      }

      if matching.nil?
        raise RewriteLambdaNotProvided, 'A rewrite was requested for ' +
            "#{caller_object}'s #{keyword} expressions, but there's no" +
            'lambda for it.'
      end

      @predicates_to_blocks[matching]
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
      if_lambda = lambda_or_raise(caller_object, :if)
      if_lambda.call(condition, then_do, else_do)
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
      and_lambda = lambda_or_raise(caller_object, :and)
      and_lambda.call(first, second)
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
      or_lambda = lambda_or_raise(caller_object, :or)
      or_lambda.call(first, second)
    end
  end


  # The global instance of RewrittenKeywords that will be used.
  # I don't normally like using global variables, but in this case
  # we need a global point of access, because we can't always control the
  # scope in which methods are executed.
  REWRITTEN_KEYWORDS = RewrittenKeywords.new({})
end
