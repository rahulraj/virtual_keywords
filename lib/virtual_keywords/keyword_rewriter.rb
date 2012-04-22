module VirtualKeywords
  # Usage: create a new KeywordRewriter, then call process on a Sexp
  class KeywordRewriter < SexpProcessor
    def initialize
      super
      self.strict = false
    end

    # Process calls this on every :if sexp. Returns a rewritten sexp.
    # Based on the example from sexps_greet.txt
    def rewrite_if(expression)
      # The sexp for the condition passed to if is inside expression[1]
      # We can further process this sexp if it has and/or in it.
      condition = expression[1]
      then_do = expression[2]
      else_do = expression[3]

      s(:fcall, :my_if,
        s(:array,
          s(:iter,
            s(:fcall, :lambda), nil, condition
          ),
          s(:iter,
            s(:fcall, :lambda), nil, then_do
          ),
          s(:iter,
            s(:fcall, :lambda), nil, else_do
          )
        )
      )
    end

    # Call a 2-argument function used to replace an operator (like "and" or "or")
    # function_name is the name of the function to call (like "my_and")
    # first and second will be wrapped in lambdas and passed to that function
    def call_operator_replacement(function_name, first, second)
      s(:fcall, function_name,
        s(:array,
          s(:iter,
            s(:fcall, :lambda), nil, first
          ),
          s(:iter,
            s(:fcall, :lambda), nil, second
          )
        )
      )
    end

    def rewrite_and(expression)
      first = expression[1]
      second = expression[2]

      call_operator_replacement(:my_and, first, second)
    end

    def rewrite_or(expression)
      first = expression[1]
      second = expression[2]

      call_operator_replacement(:my_or, first, second)
    end
  end
end
