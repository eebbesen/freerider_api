class TestUtils
  # Given a *test* value (key, etc.)
  # generate another test value by `next`ing each character
  def nextify_string(input)
    input.split('').inject('') do |string, character|
      # `[0]` because `'Z'.next == 'AA'`, `'9'.next == '10'`, etc.
      string << character.next[0]
    end
  end
end
