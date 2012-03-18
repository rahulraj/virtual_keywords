class Fizzbuzzer
  def fizzbuzz(n)
    p n
    (1..n).map { |i|
      if i % 3 == 0 and i % 5 == 0
        "fizzbuzz"
      elsif i % 3 == 0
        "fizz"
      elsif i  % 5 == 0
        "buzz"
      else
        i.to_s
      end
    }
  end
end
