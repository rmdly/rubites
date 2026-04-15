# Exercise 004: Ractor — Messaging Basics
#
# Ractors (Ruby Actors) provide true parallel execution with memory isolation.
# Unlike threads, Ractors cannot share mutable state — all communication
# happens through message passing.
#
# Core API:
#   ractor.send(msg)   — pushes a message into the ractor's inbox
#   Ractor.receive     — inside a ractor, blocks until a message arrives
#   ractor.value       — blocks until the ractor terminates, returns its
#                        final expression (like Thread#value)
#
# This worker receives a number, squares it, and returns the result.
# The caller pushes a value in with send, and retrieves the final
# result once the Ractor terminates.
#
# TODO: The caller retrieves the result with the wrong method.
# In Ruby 4, Ractors return their final value through .value,
# just like Thread#value.
#
# Expected output: square of 7 is 49

worker = Ractor.new do
  value = Ractor.receive
  value ** 2
end

worker.send(7)
puts "square of 7 is #{worker.take}"
