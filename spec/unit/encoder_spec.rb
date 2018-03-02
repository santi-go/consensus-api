require_relative '../../system/notify'
require_relative '../../system/actions/vote_action'

describe "Encoder" do
  it 'recovers encoded string' do
    origin="one string"

    encoded = Notify.encode(origin)
    decoded = Actions::VoteAction.decode(encoded)

    expect(decoded).to eq(origin)
  end

  it 'encodes string' do
    origin="one string"

    encoded = Notify.encode(origin)

    expect(encoded).not_to eq(origin)
  end

  it 'encodes with base64' do
    origin = "one string"

    encoded = Notify.encode(origin)

    expect(encoded).to eq("b25lIHN0cmluZw==")
  end
end
