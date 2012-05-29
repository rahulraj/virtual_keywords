require 'parse_tree'
require 'ruby2ruby'

require 'virtual_keywords/deep_copy_array'
require 'virtual_keywords/parser_strategy'
require 'virtual_keywords/sexp_stringifier'
require 'virtual_keywords/class_mirrorer'
require 'virtual_keywords/class_reflection'
require 'virtual_keywords/virtualizer'
require 'virtual_keywords/keyword_rewriter'
require 'virtual_keywords/rewritten_keywords'

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
