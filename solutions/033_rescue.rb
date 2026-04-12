begin
  result = 10 / 0
rescue ZeroDivisionError
  puts "Cannot divide by zero!"
ensure
  puts "Cleanup complete"
end

begin
  Integer("not a number")
rescue ArgumentError
  puts "Not a valid number"
end
