require_relative '../../system/notify'
require_relative '../../system/actions/vote_action'
require_relative '../../system/helpers/enigma'

describe "Encoder" do
  it 'recovers encoded string' do
    origin="one string"

    encoded = Enigma.encode(origin)
    decoded = Enigma.decode(encoded)

    expect(decoded).to eq(origin)
  end

  it 'encodes string' do
    origin="one string"

    encoded = Enigma.encode(origin)

    expect(encoded).not_to eq(origin)
  end

  it 'encodes with base64' do
    origin = "one string"

    encoded = Enigma.encode(origin)

    expect(encoded).to eq("b25lIHN0cmluZw==")
  end
end
