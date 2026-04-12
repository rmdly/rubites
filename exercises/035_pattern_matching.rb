# Exercise 035: Pattern Matching
#
# Ruby 3.0+ introduced pattern matching with case/in.
# It can destructure arrays, hashes, and nested structures.
# This is Ruby's most modern control flow feature.
#
# Expected output: two numbers: 1 and 2
# Expected output: Alice is 30
# Expected output: found Ruby in the data

# TODO: Fix the pattern to match an array of exactly two elements
case [1, 2]
in [a]
  puts "two numbers: #{a} and #{b}"
end

# TODO: Fix the pattern to destructure the hash
user = { name: "Alice", age: 30, role: "admin" }

case user
in { name: String => name, role: String => role }
  puts "#{name} is #{role}"
end

# TODO: Fix the pattern to find "Ruby" in a nested structure
data = { languages: { favourite: "Ruby" } }

case data
in { languages: { favourite: "Python" => lang } }
  puts "found #{lang} in the data"
end
