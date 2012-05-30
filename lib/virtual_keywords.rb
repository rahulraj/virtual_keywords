begin
  require 'parse_tree' # 1.8
rescue LoadError
  # 1.9
  require 'method_source'
  require 'ruby_parser'
  # HACK: parse_tree complains if I try to require it, but I do need the Unifier
  # class from it. So, grab it from a local copy.
  require_relative 'parsetree/lib/unified_ruby'
end
require 'ruby2ruby'

if RUBY_VERSION.start_with? '1.8'
  require 'virtual_keywords/deep_copy_array'
  require 'virtual_keywords/parser_strategy'
  require 'virtual_keywords/sexp_stringifier'
  require 'virtual_keywords/class_reflection'
  require 'virtual_keywords/virtualizer'
  require 'virtual_keywords/keyword_rewriter'
  require 'virtual_keywords/rewritten_keywords'
else
  require_relative 'virtual_keywords/deep_copy_array'
  require_relative 'virtual_keywords/parser_strategy'
  require_relative 'virtual_keywords/sexp_stringifier'
  require_relative 'virtual_keywords/class_reflection'
  require_relative 'virtual_keywords/virtualizer'
  require_relative 'virtual_keywords/keyword_rewriter'
  require_relative 'virtual_keywords/rewritten_keywords'
end

module VirtualKeywords
  class Foo
    def hi
      if true
        :hi
      else
        :bye
      end
    end
  end

  def self.sanity_test
    # TODO See if there's a way to run the specs instead of this, when
    # building the gem and requiring it
    virtualizer = Virtualizer.new(
        :for_classes => [Foo]
    )
    virtualizer.virtual_if do |condition, then_do, else_do|
      :pwned
    end

    foo = Foo.new
    if foo.hi == :pwned
      :success
    else
      :failure
    end
  end
end
