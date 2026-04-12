day = "Saturday"
age = 15

case day
when "Monday", "Tuesday", "Wednesday", "Thursday", "Friday"
  puts "weekday"
when "Saturday", "Sunday"
  puts "weekend"
end

case age
when 0..12
  puts "child"
when 13..17
  puts "teen"
when 18..120
  puts "adult"
end
