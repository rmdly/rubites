# Exercise 003: Nil
#
# In Ruby, nil represents the absence of a value.
# nil is an object (everything in Ruby is!) and has its own class: NilClass.
# You can check for nil with .nil? or compare with ==.
#
# Expected output: true
# Expected output: false
# Expected output: NilClass

nothing = nil
something = "I exist"

# TODO: Check if 'nothing' is nil
puts something.nil?

# TODO: Check if 'something' is nil
puts nothing.nil?

# TODO: Print the class of 'nothing'
puts something.class
