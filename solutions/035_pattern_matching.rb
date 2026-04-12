case [1, 2]
in [a, b]
  puts "two numbers: #{a} and #{b}"
end

user = { name: "Alice", age: 30, role: "admin" }

case user
in { name: String => name, age: Integer => age }
  puts "#{name} is #{age}"
end

data = { languages: { favourite: "Ruby" } }

case data
in { languages: { favourite: "Ruby" => lang } }
  puts "found #{lang} in the data"
end
