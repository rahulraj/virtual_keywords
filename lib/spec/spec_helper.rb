require 'sexp_processor'
require 'parse_tree'
require 'ruby2ruby'
require 'aquarium'

require 'virtual_keywords/replacements'
require 'virtual_keywords/sexp_stringifier'
require 'virtual_keywords/class_mirrorer'
require 'virtual_keywords/example_classes'
require 'virtual_keywords/if_rewriter'
require 'virtual_keywords/if_processor'

require 'rspec'

include VirtualKeywords

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter = 'documentation'
end
