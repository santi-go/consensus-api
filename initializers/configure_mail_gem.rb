require 'mail'

Mail.defaults do
  delivery_method :smtp, {
    address: 'smtp.sendgrid.net',
    port: 25,
    user_name: 'apikey',
    password: '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',
    return_response: true
  }
end
