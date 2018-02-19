require 'mail'

Mail.defaults do
  delivery_method :smtp, {
    address: 'smtp.sendgrid.net',
    port: 25,
    user_name: 'apikey',
    password: ENV['KEY'],
    return_response: true
  }
end
