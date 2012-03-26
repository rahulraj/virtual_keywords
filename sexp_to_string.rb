require 'rubygems'
require 'bundler/setup'

require 'ruby2ruby'

# Turn a sexp into a string of Ruby code
def sexp_to_string(sexp)
  unifier = Unifier.new
  ruby2ruby = Ruby2Ruby.new
  unified = unifier.process sexp
  
  ruby2ruby.process unified
end
