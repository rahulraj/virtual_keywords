# Sexps gotten from translating Greeter#greet and Greeter#greet_changed
# from example_classes.rb

# before translation (formatted manually)
s(:defn, :greet,
  s(:scope,
    s(:block, s(:args),
      s(:if, s(:ivar, :@hello),
        s(:str, "Hello World!"),
        s(:str, "Goodbye")
      )
    )
  )
)

# after translation
s(:defn, :greet_changed,
  s(:scope,
    s(:block, s(:args),
      s(:fcall, :my_if,
        s(:array,
          s(:iter,
            s(:fcall, :lambda), nil, s(:ivar, :@hello)
          ),
          s(:iter,
            s(:fcall, :lambda), nil, s(:str, "Hello World!")
          ),
          s(:iter,
            s(:fcall, :lambda), nil, s(:str, "Goodbye")
          )
        )
      )
    )
  )
)

# OK, so here's the rule that I'm inferring from this example:

# We start with 
s(:if, condition, then_do, else_do)
# Where condition, then_do, and else_do are "variables" containing
# arbitrary sexps

# Our rewriter should turn this into
s(:fcall, :my_if,
  s(:array,
    s(:iter,
      s(:fcall, :lambda), nil, ~condition
    ),
    s(:iter,
      s(:fcall, :lambda), nil, ~then_do
    ),
    s(:iter,
      s(:fcall, :lambda), nil, ~else_do
    )
  )
)
# Where ~condition is the expansion of condition, inserting the
# sexp it points to, and similar for then_do and else_do

# Question: What does the :iter part mean exactly?
# Also, how exactly does the call to lambda map to the sexp?
# It takes a block, so that complicates the syntax.
