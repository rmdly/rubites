# Exercise 034: Custom Errors
#
# Create custom error classes by inheriting from StandardError.
# This lets you raise and rescue domain-specific exceptions.
# Custom errors can carry extra data.
#
# Expected output: Age must be positive, got: -5
# Expected output: ValidationError

# TODO: Fix the custom error class to inherit from the right parent
class ValidationError < RuntimeError
  attr_reader :field

  def initialize(message, field: nil)
    super(message)
    @field = field
  end
end

# TODO: Fix the method to raise ValidationError with the right message
def validate_age(age)
  raise StandardError, "Age must be positive, got: #{age}" if age < 0
  age
end

begin
  validate_age(-5)
rescue ValidationError => e
  puts e.message
  puts e.class
end
