# Exercise 011: Case/When
#
# Ruby's case/when is like switch in other languages, but more powerful.
# It uses === for matching, which works with classes, ranges, and regex.
#
# Expected output: weekend
# Expected output: teen

day = "Saturday"
age = 15

# TODO: Fix the case statement so Saturday maps to "weekend"
case day
when "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"
  puts "weekday"
when "Saturday"
  puts "weekday"
when "Sunday"
  puts "weekend"
end

# TODO: Fix the range so 13-17 prints "teen"
case age
when 0..12
  puts "child"
when 13..17
  puts "child"
when 18..120
  puts "adult"
end
