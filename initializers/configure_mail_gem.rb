require 'mail'

def read_file
  File.open("/opt/consensus_api/password_mail.txt", "r") do |f|
    f.each_line do |line|
      return line
    end
  end
end

Mail.defaults do
  delivery_method :smtp, {
    address: 'smtp.sendgrid.net',
    port: 25,
    user_name: 'apikey',
    password: read_file,
    return_response: true
  }
end
