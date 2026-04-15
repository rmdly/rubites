# Exercise 001: Fiber — Infinite Generator
#
# Fibers are lightweight concurrency primitives for cooperative multitasking.
# Unlike threads, fibers never run in parallel — they yield control explicitly.
#
# Key mechanics:
#   fiber.resume        — starts or continues the fiber
#   Fiber.yield(val)    — suspends the fiber, returns val to the caller's resume
#
# This fiber should produce the Fibonacci sequence: 0, 1, 1, 2, 3, 5, ...
# Each call to resume should return the CURRENT number, then advance.
#
# TODO: The output is wrong — the sequence should start at 0, not 1.
# Think about which variable holds the current value and when the
# swap should happen relative to the yield.
#
# Expected output: 0
# Expected output: 1
# Expected output: 1
# Expected output: 2
# Expected output: 3

fib = Fiber.new do
  a, b = 0, 1
  loop do
    a, b = b, a + b
    Fiber.yield(b)
  end
end

5.times { puts fib.resume }
