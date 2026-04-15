# Exercise 002: Fiber — Two-Way Communication
#
# A fiber can RECEIVE values: after the first resume (which primes the
# fiber and runs it to the first Fiber.yield), each subsequent
# resume(val) delivers val as the return value of Fiber.yield inside
# the fiber.
#
# Key mechanics:
#   fiber.resume        — starts or continues the fiber
#   Fiber.yield(val)    — suspends the fiber, returns val to the caller's resume
#   fiber.resume(val)   — continues the fiber; val becomes the return of Fiber.yield
#
# The FIRST resume starts the fiber. Any argument to the first resume is
# passed as the block parameter, NOT as the return value of Fiber.yield.
# This means a fiber that receives values must be "primed" with a bare
# resume before you can start sending data into it.
#
# This should print the squares of 0 through 4.
#
# TODO: There are two bugs here. Think about what the first resume
# actually does — does it deliver a value, or just start the fiber?
# And what values should the producer be sending?
#
# Expected output: consumer got: 0
# Expected output: consumer got: 1
# Expected output: consumer got: 4
# Expected output: consumer got: 9
# Expected output: consumer got: 16

consumer = Fiber.new do
  loop do
    value = Fiber.yield
    puts "consumer got: #{value}"
  end
end

5.times do |i|
  consumer.resume(i)
end
