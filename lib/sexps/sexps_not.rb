# Before
s(:defn, :negate,
  s(:scope,
    s(:block, s(:args),
      s(:not, s(:ivar, :@value))
    )
  )
)

# After
s(:defn, :negate_result,
  s(:scope,
    s(:block, s(:args),
      s(:fcall, :my_not,
        s(:array,
          s(:iter,
            s(:fcall, :lambda), nil,
            s(:ivar, :@value)
          )
        )
      )
    )
  )
)
