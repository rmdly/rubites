# Exercise 016: Hashes
#
# Hashes are key-value pairs. Ruby has two syntax styles:
# Old style: { :key => "value" }  (hash rocket)
# New style: { key: "value" }     (symbol shorthand)
#
# Expected output: Alice
# Expected output: 30
# Expected output: {:name=>"Alice", :age=>30, :city=>"London"}

# TODO: Fix the hash - use symbol keys
person = { "name" => "Alice", "age" => 30 }

puts person[:name]
puts person[:age]

# TODO: Add a :city key with value "London"

puts person.inspect
