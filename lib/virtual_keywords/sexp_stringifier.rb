require 'ruby2ruby'

module VirtualKeywords

  # Class that turns a sexp back into a string of Ruby code.
  class SexpStringifier
    # Initialize the SexpStringifier
    #
    # Arguments:
    #   unifier: (Unifier) a Unifier, used by ParseTree/ruby2ruby (optional)
    #   ruby2ruby: (Ruby2Ruby) a Ruby2Ruby, used by ParseTree/ruby2ruby
    #              (optional)
    def initialize(unifier = Unifier.new, ruby2ruby = Ruby2Ruby.new)
      @unifier = unifier
      @ruby2ruby = ruby2ruby
    end

    # Turn a sexp into a string of Ruby code.
    #
    # Arguments:
    #   sexp: (Sexp) the sexp to be stringified.
    #
    # Returns:
    #   (String) Ruby code equivalent to the sexp.
    def stringify(sexp)
      @ruby2ruby.process(@unifier.process(sexp))
    end
  end
end
