require 'ruby2ruby'

module VirtualKeywords
  # Turn a sexp into a string of Ruby code.
  #
  # Arguments:
  #   sexp: (Sexp) the sexp to be stringified.
  #
  # Returns:
  #   (String) Ruby code equivalent to the sexp.
  def sexp_to_string(sexp)
    unifier = Unifier.new
    ruby2ruby = Ruby2Ruby.new
    unified = unifier.process sexp
    
    ruby2ruby.process unified
  end
end
