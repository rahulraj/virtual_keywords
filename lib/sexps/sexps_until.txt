# Before
s(:defn, :until_count_to_value,
  s(:scope,
    s(:block, s(:args),
      s(:until,
        # Condition
        s(:call, s(:ivar, :@i), :>,
          s(:array, s(:ivar, :@value))
        ),
        # Body
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
        # TODO Again, I'm not sure what this true is for
        true
      ),
      s(:ivar, :@counts)
    )
  )
)

# After
s(:defn, :until_result,
  s(:scope,
    s(:block, s(:args),
      s(:fcall, :my_until,
        s(:array,
          s(:iter,
            s(:fcall, :lambda), nil,
            # Condition
            s(:call, s(:ivar, :@i), :>,
              s(:array, s(:ivar, :@value))
            )
          ),
          s(:iter,
            s(:fcall, :lambda), nil,
            # Body
            s(:block,
              s(:call, s(:ivar, :@counts), :<<,
                s(:array, s(:ivar, :@i))
              ),
              s(:iasgn, :@i,
                s(:call, s(:ivar, :@i), :+,
                  s(:array, s(:lit, 1)))
              )
            )
          )
        )
      ),
      s(:ivar, :@counts)
    )
  )
)
