require 'base64'

class Enigma
  class << self
    def encode(token)
      Base64.strict_encode64(token)
    end

    def decode(token)
      Base64.strict_decode64(token)
    end
  end
end
