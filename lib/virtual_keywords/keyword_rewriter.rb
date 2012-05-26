module VirtualKeywords
  class IfRewriter < SexpProcessor
    # Initialize an IfRewriter (self.strict is false)
    def initialize
      super
      self.strict = false
    end

    # Rewrite an :if sexp. SexpProcessor#process is a template method that will
    # call this method every time it encounters an :if.
    #
    # Arguments:
    #   expression: (Sexp) the :if sexp to be rewritten.
    #
    # Returns:
    #   (Sexp) A rewritten sexp that calls
    #   VirtualKeywords::REWRITTEN_KEYWORDS.call_if with the condition,
    #   then clause, and else clause as arguments, all wrapped in lambdas.
    #   It must also pass self to call_if, so REWRITTEN_KEYWORDS can decide
    #   which of the lambdas registered with it should be called.
    def rewrite_if(expression)
      # The sexp for the condition passed to if is inside expression[1]
      # We can further process this sexp if it has and/or in it.
      condition = expression[1]
      then_do = expression[2]
      else_do = expression[3]

      # This ugly sexp turns into the following Ruby code:
      # VirtualKeywords::REWRITTEN_KEYWORDS.call_if(
      #     self, lambda { condition }, lambda { then_do }, lambda { else_do })
      s(:call,
        s(:colon2,
          s(:const, :VirtualKeywords),
          :REWRITTEN_KEYWORDS
        ), :call_if,
        s(:array,
          s(:self),
          s(:iter, s(:fcall, :lambda), nil, condition),
          s(:iter, s(:fcall, :lambda), nil, then_do),
          s(:iter, s(:fcall, :lambda), nil, else_do)
        )
      )
    end
  end

  # Helper method. Call a 2-argument function used to replace an operator
  # (like "and" or "or")
  #
  # Arguments:
  #   method_name: (Symbol) the name of the REWRITTEN_KEYWORDS method that
  #                should be called in the sexp.
  #   first: (Sexp) the first argument to the method, which should be
  #          wrapped in a lambda then passed to REWRITTEN_KEYWORDS. 
  #   second: (Sexp) the second argument to the method, which should be
  #            wrapped in a lambda then passed to REWRITTEN_KEYWORDS. 
  def self.call_operator_replacement(function_name, first, second)
    s(:call,
      s(:colon2,
        s(:const, :VirtualKeywords),
        :REWRITTEN_KEYWORDS
      ), function_name,
      s(:array,
        s(:self),
        s(:iter, s(:fcall, :lambda), nil, first),
        s(:iter, s(:fcall, :lambda), nil, second)
      )
    )
  end

  class AndRewriter < SexpProcessor
    def initialize
      super
      self.strict = false
    end

    # Rewrite "and" expressions (automatically called by SexpProcessor#process)
    #
    # Arguments:
    #   expression: (Sexp) the :and sexp to rewrite.
    #
    # Returns:
    #   (Sexp): a sexp that instead calls REWRITTEN_KEYWORDS.call_and
    def rewrite_and(expression)
      first = expression[1]
      second = expression[2]

      VirtualKeywords.call_operator_replacement(:call_and, first, second)
    end
  end

  class OrRewriter < SexpProcessor
    def initialize
      super
      self.strict = false
    end
  
    # Rewrite "or" expressions (automatically called by SexpProcessor#process)
    #
    # Arguments:
    #   expression: (Sexp) the :or sexp to rewrite.
    #
    # Returns:
    #   (Sexp): a sexp that instead calls REWRITTEN_KEYWORDS.call_or
    def rewrite_or(expression)
      first = expression[1]
      second = expression[2]

      VirtualKeywords.call_operator_replacement(:call_or, first, second)
    end
  end
end
