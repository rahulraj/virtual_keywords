require 'rubygems'
require 'bundler/setup'

require 'parse_tree'

# Simple data object holding a Class and a name of one of the methods
# in the class.
ClassAndMethodName = Struct.new(:klass, :method_name)

# Given a parser (default is ParseTree), return a lambda that does
# the following:
# Given a list of classes, return a hash mapping ClassAndMethodNames to
# outputs of parser.translate (which is a nested Array for ParseTree)
# There is an entry for every method in every class from klasses
def new_class_mirrorer(parser=ParseTree)
  lambda { |klasses|
    methods = {}
    klasses.each do |klass|
      klass.instance_methods.each do |method_name|
        key = ClassAndMethodName.new(klass, method_name)
        translated = parser.translate(klass, method_name)
        methods[key] = translated
      end 
    end

    methods
  }
end
