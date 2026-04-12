def sandwich
  puts "before"
  yield
  puts "after"
end

sandwich { puts "I'm in the block!" }

def maybe_yield
  if block_given?
    yield
  else
    puts "No block given"
  end
end

maybe_yield
