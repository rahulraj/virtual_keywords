# Functions with which to replace if, "and", and "or" statements

# Call count for testing
$my_if_calls = 0
$my_and_calls = 0

def my_if(a, b, c)
  $my_if_calls += 1
  if a.call then b.call else c.call end
end

def my_and(a, b)
  $my_and_calls += 1
  a.call and b.call
end
