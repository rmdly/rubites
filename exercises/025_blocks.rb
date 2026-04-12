# Exercise 025: Blocks
#
# Blocks are anonymous chunks of code passed to methods.
# Use 'yield' inside a method to call the block.
# 'block_given?' checks if a block was passed.
#
# Expected output: before
# Expected output: I'm in the block!
# Expected output: after
# Expected output: No block given

# TODO: Fix the method to yield to the block between "before" and "after"
def sandwich
  puts "before"
  puts "after"
end

sandwich { puts "I'm in the block!" }

# TODO: Fix the method to check if a block was given
def maybe_yield
  puts "I'll yield if I can"
end

maybe_yield
