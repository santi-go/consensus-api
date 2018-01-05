def create_subject(text)
  opening_paragraph_pattern = /<p>/
  starting_br_with_blank_space_pattern = /^(\s*<br>\s*)*/

  text = text.gsub(opening_paragraph_pattern, "")
  text = text.gsub(starting_br_with_blank_space_pattern, "")

  if text.include? "</p>" then
    index_p_end = text.index('</p>')
    if (index_p_end > 0) then
      text = text[0, index_p_end]
    end
  end

  if text.include? "<br>" then
    index_break_line = text.index('<br>')
    if (index_break_line > 0) then
      text = text[0, index_break_line]
    end
  end

  text = text.split[0..5].join(" ")

  if text.include?(".")
    length_to_dot = text.index(".")
    return text[0, length_to_dot + 1]
  else
      text + "..."
  end
end

def remove_repeated_emails(circle, proposer)
  cleaned_circle = []
  list = circle + [proposer]
  list.each do
    |element| cleaned_circle << element unless cleaned_circle.include?(element)
  end
  cleaned_circle
end
