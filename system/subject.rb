class Subject
  class<<self
    def create(text)
      max_words = 6
      result = extract_first_sentence(text)
      result = strip_html(result)

      if (words_of(result) > max_words)
        result = first_words(result , max_words)
      end
      result
    end

  private

    def first_words(text, words_number)
      tokens = text.split(' ')
      first_words = tokens[0...words_number]
      first_words.join(' ')+'...'
    end

    def extract_first_sentence(text)
      position = text.index('.')
      return text unless position
      text[0..position]
    end

    def strip_html(sentence)
      sentence.gsub( %r{</?[^>]+?>}, ' ' ).strip
    end

    def words_of(text)
      text.split.length
    end
  end
end
