module VirtualKeywords
  class SexpStringifier
    # Factory method
    # Create the appropriate strategy object for the current Ruby version.
    def self.new
      ParseTreeSexpStringifier.new(Unifier.new, Ruby2Ruby.new)
    end
  end

  # Similar to ParserStrategy, we need to run slightly different code
  # based on the Ruby version.
  # When using ParseTree, we need to use a Unifier, but we don't need
  # one when using ruby_parser
  # Class that turns a sexp back into a string of Ruby code.
  class ParseTreeSexpStringifier
    # Initialize the SexpStringifier
    #
    # Arguments:
    #   unifier: (Unifier) a Unifier, used by ParseTree/ruby2ruby (optional)
    #   ruby2ruby: (Ruby2Ruby) a Ruby2Ruby, used by ParseTree/ruby2ruby
    #              (optional)
    def initialize(unifier, ruby2ruby)
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
