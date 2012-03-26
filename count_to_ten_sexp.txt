# Sexp for Greeter#count_to_ten
s(:defn, :count_to_ten,
  s(:scope,
    s(:block, s(:args),
      s(:iter,
        s(:call, s(:array, s(:lit, 1..10)), :each),
        s(:dasgn_curr, :index),
        s(:fcall, :puts, s(:array, s(:dvar, :index)))
      )
    )
  )
)
