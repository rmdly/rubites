class ValidationError < StandardError
  attr_reader :field

  def initialize(message, field: nil)
    super(message)
    @field = field
  end
end

def validate_age(age)
  raise ValidationError, "Age must be positive, got: #{age}" if age < 0
  age
end

begin
  validate_age(-5)
rescue ValidationError => e
  puts e.message
  puts e.class
end
