# Structure of a while
# So the first element is the condition, and the second is the body, wrapped
# in a :block (TODO and then a "true", what is it for?)
s(:defn, :while_count_to_value,
  s(:scope,
    s(:block, s(:args),
      s(:while,
        # The condition
        s(:call, s(:ivar, :@i), :<,
          s(:array, s(:vcall, :value))
        ),
        # End condition
        # The body
        s(:block,
          s(:call, s(:ivar, :@counts), :<<,
            s(:array, s(:ivar, :@i))
          ),
          s(:iasgn, :@i,
            s(:call, s(:ivar, :@i), :+,
              s(:array, s(:lit, 1))
            )
          )
        ),
        # End body
        true
      )
    )
  )
)

# After
s(:defn, :while_result,
  s(:scope,
    s(:block, s(:args),
      s(:fcall, :my_while,
        s(:array,
          s(:iter,
            s(:fcall, :lambda), nil,
            # The condition
            s(:call, s(:ivar, :@i), :<,
              s(:array, s(:vcall, :value))
            )
            # End condition
          ),
          s(:iter,
            s(:fcall, :lambda), nil,
            # The body
            s(:block,
              s(:call, s(:ivar, :@counts), :<<,
                s(:array, s(:ivar, :@i))
              ),
              s(:iasgn, :@i,
                s(:call, s(:ivar, :@i), :+,
                  s(:array, s(:lit, 1))
                )
              )
            )
            # End body
          )
        )
      )
    )
  )
)

