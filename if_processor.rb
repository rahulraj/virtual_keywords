require 'rubygems'
require 'bundler/setup'

require 'parse_tree'

# Usage: create a new IfProcessor, then call process on a Sexp
class IfProcessor < SexpProcessor
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
end
