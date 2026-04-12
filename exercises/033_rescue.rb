# Exercise 033: Begin/Rescue
#
# Ruby uses begin/rescue/ensure for error handling.
# rescue catches exceptions, ensure always runs.
# You can rescue specific exception types.
#
# Expected output: Cannot divide by zero!
# Expected output: Cleanup complete
# Expected output: Not a valid number

# TODO: Fix the rescue to catch ZeroDivisionError
begin
  result = 10 / 0
rescue TypeError
  puts "Cannot divide by zero!"
ensure
  puts "Cleanup complete"
end

# TODO: Fix the rescue to catch the right error type
begin
  Integer("not a number")
rescue ZeroDivisionError
  puts "Not a valid number"
end
