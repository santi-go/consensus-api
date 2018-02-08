require_relative '../../system/notifications/mailer'
require_relative '../test_support/doubles/mail'

RSpec.describe Notifications::Mailer do
  it 'wraps Mail gem' do
    stub_const('Mail', TestSupport::Doubles::Mail)
    mailer = Notifications::Mailer

    captured_mail = mailer.deliver(:some_origin, :some_destiny, :some_subject, :some_body)

    expect(captured_mail.delivered).to eq(expected_mail)
  end

  def expected_mail
    {
      origin: :some_origin,
      destiny: :some_destiny,
      subject: :some_subject,
      body: :some_body
    }
  end
end
