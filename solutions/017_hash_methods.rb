person = { name: "Alice", age: 30 }
address = { city: "London", country: "UK" }

puts person.keys.inspect

nested = { user: { profile: { name: "Alice" } } }
puts nested.dig(:user, :profile, :name)

combined = person.merge(address)
puts combined[:city]
