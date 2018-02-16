require_relative '../../initializers/configure_mail_gem'


RSpec.describe 'password method' do
  it 'reads file' do
    result = read_file

    password = "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"

    expect(result).to eq(password)
  end

  it 'give password' do
    hola = {
        password: read_file
    }
    password = "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"

    expect(hola[:password]).to eq(password)
  end
end
