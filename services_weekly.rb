require 'logger'

def grab_salesforce_config
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/weekly.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  config = Hash.new

  logger.info('getting config file')
  open "#{File.dirname(__FILE__)}/etc/salesforce.conf" do |config_file|
    config_file.each_line do |line|
      unless line.chomp.empty? || line =~ /^#/
        username, pass, sec, client_id, client_sec = line.split ','
        config = { username: username,
                   password: pass,
                   security_token: sec,
                   client_id: client_id,
                   client_secret: client_sec
                 }
      end
    end
  end
  logger.info("got config for #{config[:user_name]}")
  config
end