Virtual Keywords
================

This library extends the Ruby language, making it possible to override keywords
like "if", "and", and "or" with your own implementations. It uses ParseTree to
inspect Ruby code, and replaces calls to these keywords with calls to blocks
you define.

Motivation
----------
Ruby is a relatively malleable language; it provides several facilities allowing
developers to create their own domain-specific languages (DSLs). For example,
the behavior-driven design library RSpec allows users to write
```ruby
result.should eql :answer
```
and its implementation is much easier in Ruby than in many other languages --
just reopen the Object class and add a should method!

This flexibility has its limits. Look at "if" statements:
```ruby
if condition
  do_something()
else
  do_something_else()
end
```
