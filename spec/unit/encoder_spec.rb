require 'base64'

describe "Encoder" do
  it 'recovers encoded string' do
    origin="one string"

    encoded = encode_string(origin)
    decoded = decode_string(encoded)

    expect(decoded).to eq(origin)
  end

  it 'encodes string' do
    origin="one string"

    encoded =encode_string(origin)

    expect(encoded).not_to eq(origin)
  end

  it 'encodes with base64' do
    origin = "one string"

    encoded = encode_string(origin)

    expect(encoded).to eq("b25lIHN0cmluZw==")
  end
end


def encode_string (text)
  Base64.strict_encode64(text)
end

def decode_string (text)
  Base64.strict_decode64(text)
end
