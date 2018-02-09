class JSONValidator
  class << self
    def validate_create_proposal?(data)
      return true if ((complete_fields_for_create_proposal?(data) && empty_field?(data) && has_fields_to_create_proposal(data)))
      false
    end

  private

    def empty_field?(data)
      return false if data.has_value?(nil)
      true
    end

    def has_fields_to_create_proposal(data)
      if (data.has_key?(:proposer) && data.has_key?(:circle) && data.has_key?(:proposal))
        return true
      else
        return false
      end
    end

    def complete_fields_for_create_proposal?(data)
      return false if (data[:proposer] == '' || data[:circle] == [] || data[:proposal] == '')
      true
    end
  end
end
