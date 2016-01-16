class TestUtils

  # Given a *test* value (key, etc.) 
  # generate another test value by `next`ing each character
  def self.nextify_string(input)
    input.split('').inject('') do |string, character|
      # `first` because `'Z'.next == 'AA'`, `'9'.next == '10'`, etc.
      string += character.next.first
    end
  end
end
