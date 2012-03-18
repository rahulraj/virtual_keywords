# Bundler requires these 2 lines
require 'rubygems'
require 'bundler/setup'

# rewrite attempts to send the message 'to_sexp' to Proc objects.
# That is defined in 'parse_tree_extensions' which it doesn't require.
# (Maybe a ParseTree library change broke rewrite?)
#require 'parse_tree_extensions'
#require 'rewrite'

#include Rewrite::With
#include Rewrite::Prelude

# andand doesn't work!! Tries to send the method '[]' to nil!
#with(andand) do
  #greeting = 'Hello World!'
  #puts greeting.andand.reverse
#end

# Also prints a massive stack trace
#with(try) do
  #greeting = 'Hello World!'
  #greeting.try(:reverse)
#end


# OK, let's try a different angle. Use ParseTree and Ruby2Ruby directly
# http://stackoverflow.com/questions/4809073/is-ruby2ruby-compatible-with-parsetree 
require 'ruby2ruby'
require 'parse_tree'
require 'unified_ruby'

code = 'puts(2)'
# This turns the code into a sexp object, which we can modify 
translated = ParseTree.translate code
sexp = SexpProcessor.new.process translated

puts sexp

puts 'Processing the sexp...'

# And then this turns the sexp back into a string, which can be evaled
unified_sexp = Unifier.new.process(sexp)
code = Ruby2Ruby.new.process(unified_sexp)
puts code
eval code # Works!

# OK, now try doing it to a given function instead of a string
require 'parse_tree_extensions' # for to_ruby

def frobnicate(number)
  number * 4 + 3
end
more_code = method(:frobnicate).to_ruby # more_code is a String
# Turn it into a sexp, works!
frobnicate_as_sexp = SexpProcessor.new.process(ParseTree.translate(more_code))
# After modifying it, we can turn it back into a string and eval it
# (or is there a better way?)

# TODO
# 1. Figure out how to traverse sexps and modify them
# 2. Figure out how to use this to modify if statements
#    IDEA: Use Aquarium (aspect-oriented-programming). It lets us intercept
#    method calls, so when it fires, take the method being called, use to_ruby
#    on it, and modify that. Then run the modified method instead of the
#    original.
# 3. If we're not using rewrite, maybe we should use sourcify instead
#    of ParseTree, so that we don't break on rubies 1.9 and newer.
