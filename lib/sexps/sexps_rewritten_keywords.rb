# before
s(:defn, :greet_if_else,
  s(:scope,
    s(:block, s(:args),
      s(:if,
        s(:ivar, :@hello),
        s(:str, "Hello World! (if else)"),
        s(:call, s(:str, "Good"), :+, s(:array, s(:str, "bye (if else)")))
      )
    )
  )
)

#after
s(:defn, :greet_changed,
  s(:scope,
    s(:block, s(:args),
      s(:call,
        s(:colon2,
          s(:const, :VirtualKeywords),
          :REWRITTEN_KEYWORDS
        ),
        :call_if,
          s(:array,
            s(:self),
            s(:iter, s(:fcall, :lambda), nil, s(:ivar, :@hello)),
            s(:iter, s(:fcall, :lambda), nil, s(:str, "Hello World! (if else)")),
            s(:iter,
              s(:fcall, :lambda),
              nil, s(:call, s(:str, "Good"), :+, s(:array, s(:str, "bye (if else)")))
            )
          )
      )
    )
  )
)
