require 'ruby-pardot'
require 'logger'

# Gets the woodpecker configuration api key
def grab_woodpecker_config
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/api.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  key = ""

  logger.info('getting woodpecker config file')
  open "#{File.dirname(__FILE__)}/etc/woodpecker.conf" do |config_file|
    config_file.each_line do |line|
      unless line.chomp.empty? || line =~ /^#/
        key = line.split ','
      end
    end
  end
  logger.info("got key")
  key
end

# Gets pardot configuration key and password data
def grab_pardot_config
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/api.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  config = Hash.new

  logger.info('getting config file')
  open "#{File.dirname(__FILE__)}/etc/pardot.conf" do |config_file|
    config_file.each_line do |line|
      unless line.chomp.empty? || line =~ /^#/
        email, pass, key = line.split ','
        config = { user_email: email,
                   user_pass: pass,
                   user_key: key }
      end
    end
  end
  logger.info("got config for #{config[:user_email]}")
  config
end

# Gets Salesforce configurations
def grab_salesforce_config
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/api.log", 0, 100 * 1024 * 1024)
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
  logger.info("got config for #{config['user_name']}")
  config
end