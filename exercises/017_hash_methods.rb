# Exercise 017: Hash Methods
#
# Hashes have useful methods: .keys, .values, .has_key?, .merge, .dig
# .dig safely navigates nested hashes without raising errors.
#
# Expected output: [:name, :age]
# Expected output: Alice
# Expected output: London

person = { name: "Alice", age: 30 }
address = { city: "London", country: "UK" }

# TODO: Print just the keys of person
puts person.values.inspect

# TODO: Use .dig to safely get the name
nested = { user: { profile: { name: "Alice" } } }
puts nested[:user][:name]

# TODO: Merge person and address, then get :city
combined = person
puts combined[:city]
