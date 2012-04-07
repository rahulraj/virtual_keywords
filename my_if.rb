# Call count for testing
$my_if_calls = 0

def my_if(a, b, c)
  $my_if_calls += 1
  if a.call then b.call else c.call end
end
