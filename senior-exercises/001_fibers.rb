# Exercise 001: Fibers
#
# Fibers are lightweight concurrency primitives for cooperative multitasking.
# Unlike threads, fibers never run in parallel — they yield control explicitly.
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
# Expected output: 0
# Expected output: 1
# Expected output: 1
# Expected output: 2
# Expected output: 3
# Expected output: consumer got: 0
# Expected output: consumer got: 1
# Expected output: consumer got: 4
# Expected output: consumer got: 9
# Expected output: consumer got: 16
# Expected output: [6, 12, 18, 24, 30]

# --- Part 1: Infinite Fibonacci generator ---
#
# This fiber should produce the Fibonacci sequence: 0, 1, 1, 2, 3, 5, ...
# Each call to resume should return the CURRENT number, then advance.
#
# TODO: The output is wrong — the sequence should start at 0, not 1.
# Think about which variable holds the current value and when the
# swap should happen relative to the yield.
fib = Fiber.new do
  a, b = 0, 1
  loop do
    a, b = b, a + b
    Fiber.yield(b)
  end
end

5.times { puts fib.resume }

# --- Part 2: Two-way communication ---
#
# A fiber can RECEIVE values: after the first resume (which primes the
# fiber and runs it to the first Fiber.yield), each subsequent
# resume(val) delivers val as the return value of Fiber.yield inside
# the fiber.
#
# This should print the squares of 0 through 4.
#
# TODO: There are two bugs here. Think about what the first resume
# actually does — does it deliver a value, or just start the fiber?
# And what values should the producer be sending?
consumer = Fiber.new do
  loop do
    value = Fiber.yield
    puts "consumer got: #{value}"
  end
end

5.times do |i|
  consumer.resume(i)
end

# --- Part 3: Fiber pipeline ---
#
# Three fibers form a pull-based pipeline:
#   source → doubler → tripler → results
#
# Each stage calls resume on the PREVIOUS stage to pull a value,
# transforms it, and yields the result downstream.
#
# For input [1,2,3,4,5]: doubled then tripled → [6, 12, 18, 24, 30]
#
# TODO: There are two bugs in this pipeline. One is in source (what
# does Fiber.yield return when you don't pass it an argument?), and
# one is in tripler (which upstream stage should it pull from?).
source = Fiber.new do
  [1, 2, 3, 4, 5].each { |n| Fiber.yield }
end

doubler = Fiber.new do
  loop do
    val = source.resume
    Fiber.yield(val * 2)
  end
end

tripler = Fiber.new do
  loop do
    val = source.resume
    Fiber.yield(val * 3)
  end
end

results = []
5.times { results << tripler.resume }
puts results.inspect
