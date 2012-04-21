# Sexps from translating Greeter#method_with_and and
# Greeter#method_with_and_result (example_classes.rb)

# before
s(:defn, :method_with_and,
  s(:scope,
    s(:block, s(:args),
      s(:and, s(:ivar, :@hello), s(:true))
    )
  )
)

# after
s(:defn, :method_with_and_result,
  s(:scope,
    s(:block, s(:args),
      s(:fcall, :my_and,
        s(:array,
          s(:iter,
            s(:fcall, :lambda), nil, s(:ivar, :@hello)
          ),
          s(:iter,
            s(:fcall, :lambda), nil, s(:true)
          )
        )
      )
    )
  )
)
