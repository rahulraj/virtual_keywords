$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'virtual_keywords/version'

Gem::Specification.new do |specification|
  specification.name  = 'virtual_keywords'
  specification.version = VirtualKeywords::VERSION
  specification.date = '2012-04-21'
  specification.summary = 'Virtualize keywords, like "if", "and", and "or"'
  specification.description = 'Replace keyword implementations with your own ' +
      'functions, for DSLs'
  specification.authors = ['Rahul Rajagopalan']
  specification.email = 'rahulrajago@gmail.com'
  specification.files = Dir.glob('{bin,lib}/**/*')
  specification.homepage = 'http://github.com/rahulraj/virtual_keywords'
  
  specification.add_development_dependency 'rspec'
  specification.add_runtime_dependency 'sexp_processor'
  specification.add_runtime_dependency 'ParseTree'
  specification.add_runtime_dependency 'ruby2ruby'
  specification.add_runtime_dependency 'method_source'
  specification.add_runtime_dependency 'ruby_parser'
end
