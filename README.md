Virtual Keywords
================

virtual\_keywords extends the Ruby language, making it possible to override
keywords like "if", "and", and "or" with your own implementations. It uses
ParseTree and ruby\_parser to inspect Ruby code, and replaces expressions
using these keywords with calls to blocks you define.

Motivation
----------
Ruby is a relatively malleable language; it provides several facilities allowing
developers to create their own domain-specific languages (DSLs). For example,
the behavior-driven design library RSpec allows users to write:
```ruby
result.should eql :answer
```
and its implementation is much easier in Ruby than in many other languages --
just reopen the Object class and add a should method!

This flexibility has its limits. Look at "if" statements:
```ruby
if condition
  do_something
else
  do_something_else
end
```
There isn't an out-of-the-box way to override this. Ruby will evaluate
condition, then evaluate either do_something or do_something_else depending
on whether condition was true, and you can't redefine this behavior.

Smalltalk, Clojure, Scala, and a handful of other languages don't have this
issue, so this limitation makes Ruby feel more cumbersome by comparison.

virtual_keywords brings this flexibility to Ruby, completing the idea of an
extensible language with rich syntax. Currently, users can override "if",
"and", "or", "not", "while", and "until" and more is on the way!

Usage
-----
First, install the gem:
```sh
gem install virtual_keywords
```

Then, require it:
```ruby
require 'virtual_keywords'
```

Next, specify what you want to virtualize. Create a Virtualizer object, passing
it the objects whose methods you want to virtualize.
```ruby
virtualizer = VirtualKeywords::Virtualizer.new(
    :for_instances => [foo, bar],
    :for_classes => [Baz],
    :for_subclasses_of => [ParentClass]
)
```
All three of these named parameters are optional. Objects passed through
for_instances will have all their methods virtualized. The for_classes array
contains classes, and all objects created from the given classes will be
virtualized. Finally, classes passed through for_subclasses_of will have all
objects created through their subclasses virtualized.

Finally, provide alternate implementations of the keywords you want to replace.
You can replace as many or as few of the keywords as you want.
To rewrite "if" conditionals, call the virtual_if method, and pass in a block
containing your modified implementation of "if" conditionals. For example:
```ruby
virtualizer.virtual_if do |condition, then_do, else_do|
  # condition, then_do, and else_do are lambdas wrapping the condition of the
  # if statement, the clause to do if the condition is true, and the clause
  # to do if the condition is false (or a no-op if no else clase was provided)

  # They have not yet been evaluated. You can evaluate them as many or as few
  # times as you want by executing the call method on them.

  # For example, this code makes a virtual "if" that's identical to a normal
  # one:
  # if condition.call
  #  then_do.call
  # else
  #   else_do.call
  # end

  # Your code here
  # ...
end
```
The Virtualizer object will respond to this method call by rewriting all "if"
expressions in the objects specified in the constructor to call your block.

"and" and "or" take two parameters, instead of three. You'd rewrite them like
this:
```ruby
virtualizer.virtual_and do |first, second|
  # first and second are the first and second operands of the "and" operator,
  # again wrapped in lambdas.
end
```
"or" is virtualized using virtualizer.virtual_or, which is similar
to virtual_and.

The block passed to virtual_not takes one parameter (a lambda wrapping the
object whose boolean value would normally be inverted).
virtual_while and virtual_until's blocks take two parameters: the first is the
condition and the second is the body of the loop (wrapped in lambdas).

You can of course create multiple Virtualizer objects, each operating on
different objects or classes, if you want to use different implementations of
the keywords for each class.

Ruby Version Compatibility
--------------------------
virtual_keywords has been tested on Rubies 1.8.7 and 1.9.3. ParseTree
doesn't work in Ruby 1.9, so virtual_keywords detects the version it's running
in, and falls back to ruby_parser if necessary. virtual_keywords will work on
Ruby 1.9, but it can't handle all cases.

In particular, ruby_parser fails when parsing code
that uses the new syntax from 1.9 (e.g. the { foo: bar } hash literal form)
but it can handle code written in Ruby 1.9 that doesn't use new syntax.
