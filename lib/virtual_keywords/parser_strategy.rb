module VirtualKeywords
  class ParserStrategy
    # Factory method
    # Create the appropriate strategy object for the current Ruby version.
    def self.new
      ParseTreeStrategy.new(ParseTree, SexpProcessor.new)
    end
  end
  # One problem that needs to be solved is that of converting source code form
  # files into sexps.

  # In Ruby 1.8, we use ParseTree and then SexpProcessor.
  # In Ruby 1.9, we use RubyParser.
  # Note that neither set of libraries seems to work in the other version.
  # Use the strategy pattern, and initialize whichever class is appropriate.
  class ParseTreeStrategy
    def initialize(parse_tree, sexp_processor)
      @parse_tree = parse_tree
      @sexp_processor = sexp_processor
    end

    def translate_instance_method(klass, method_name)
      @sexp_processor.process(@parse_tree.translate(klass, method_name))
    end
  end
end
