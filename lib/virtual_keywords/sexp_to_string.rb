require 'ruby2ruby'

module VirtualKeywords
  # Turn a sexp into a string of Ruby code
  def sexp_to_string(sexp)
    unifier = Unifier.new
    ruby2ruby = Ruby2Ruby.new
    unified = unifier.process sexp
    
    ruby2ruby.process unified
  end
end
