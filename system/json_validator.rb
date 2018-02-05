class Json_validator
  def validate_create_proposal?(data)
    return true if ((complete_fields?(data) && empty_field?(data)))
    false
  end

private

  def empty_field?(data)
    return false if data.has_value?(nil)
    true
  end

  def complete_fields?(data)
    return false if (data[:proposer] == '' || data[:circle] == [] || data[:proposal] == '')
    true
  end
end
