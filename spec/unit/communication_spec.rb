require_relative '../test_support/doubles/mailer'
require_relative '../../system/communication'

RSpec.describe Communication do
  after do
    TestSupport::Doubles::Mailer.clear
  end

  it 'sends emails' do
    stub_const('Notifications::Mailer', TestSupport::Doubles::Mailer)
    origin = 'some_sender_email'
    destiny = 'some_recipient_email'
    subject = 'some_subject'
    body = 'some_body'

    Communication.deliver(origin, destiny, subject, body)

    expect(TestSupport::Doubles::Mailer.delivered_mail).to eq(expected_delivered_mail)
  end

  def expected_delivered_mail
    {
      origin: 'some_sender_email',
      destiny: 'some_recipient_email',
      subject: 'some_subject',
      body: 'some_body'
    }
  end
end
