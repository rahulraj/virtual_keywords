s(:defn, :symbolic_and,
  s(:scope,
    s(:block, s(:args),
      s(:and, s(:ivar, :@value), s(:false))
    )
  )
)

# after
s(:defn, :symbolic_and_result,
  s(:scope,
    s(:block, s(:args),
      s(:fcall, :my_conditional_and,
        s(:array,
          s(:iter,
            s(:fcall, :lambda), nil, s(:ivar, :@value)
          ),
          s(:iter,
            s(:fcall, :lambda), nil, s(:false)
          )
        )
      )
    )
  )
)
