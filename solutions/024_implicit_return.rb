def add(a, b)
  result = a + b
  result
end

puts add(5, 10)

def describe_number(n)
  return "negative" if n < 0
  return "zero" if n == 0
  "positive"
end

puts describe_number(-5)
puts describe_number(0)
