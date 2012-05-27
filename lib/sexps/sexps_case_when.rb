# Before translation
# Ok, so each s(:when) has 2 elements: the condition and the consequence
# They're not wrapped in an array or anything, so this is a lot more
# complicated...
s(:defn, :describe_value,
  s(:scope,
    s(:block, s(:args),
      s(:case, s(:ivar, :@value),
        s(:when,
          s(:array, s(:lit, 1)),
          s(:lit, :one)
        ),
        s(:when,
          s(:array, s(:lit, 3..5)),
          s(:lit, :three_to_five)
        ),
        s(:when,
          s(:array, s(:lit, 7), s(:lit, 9)),
          s(:lit, :seven_or_nine)
        ),
        s(:when,
          s(:array,
            s(:call,
              s(:call, s(:vcall, :value), :*, s(:array, s(:lit, 10))),
              :<, s(:array, s(:lit, 90))
            )
          ),
          s(:lit, :passes_multiplication_test)
        ),
        s(:lit, :something_else)
      )
    )
  )
)
