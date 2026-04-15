# Exercise 003: Fiber — Pipeline
#
# Three fibers form a pull-based pipeline:
#   source → doubler → tripler → results
#
# Each stage calls resume on the PREVIOUS stage to pull a value,
# transforms it, and yields the result downstream.
#
# Key mechanics:
#   fiber.resume        — starts or continues the fiber
#   Fiber.yield(val)    — suspends the fiber, returns val to the caller's resume
#
# For input [1,2,3,4,5]: doubled then tripled → [6, 12, 18, 24, 30]
#
# TODO: There are two bugs in this pipeline. One is in source (what
# does Fiber.yield return when you don't pass it an argument?), and
# one is in tripler (which upstream stage should it pull from?).
#
# Expected output: [6, 12, 18, 24, 30]

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
