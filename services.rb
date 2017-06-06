require 'ruby-pardot'
require 'logger'

def email_grab(prospects)
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/log.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG
  signups = []
  prospects["prospect"].each do |prospect|
    logger.info("Getting #{prospect['email']} Prospect")
    signups << prospect["email"]
  end
  logger.info("Got signups #{signups}")
  signups
end

def recent_newsletter_list
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/log.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  # Starts by getting Pardot config
  config = Hash.new

  logger.info('getting config file')
  open "#{File.dirname(__FILE__)}/etc/pardot.conf" do |config_file|
    config_file.each_line do |line|
      unless line.chomp.empty? || line =~ /^#/
        email, pass, key = line.split ','
        config = {
          user_email: email,
          user_pass: pass,
          user_key: key
        }
      end
    end
  end
  logger.info("got config for #{config[:user_email]}")

  # Authenticate pardot connection
  logger.info('Attempting authentication . . .')
  begin
    client = Pardot::Client.new config[:user_email], config[:user_pass], config[:user_key]
    client.authenticate
    logger.info('Authentication successful')
  rescue e
    logger.info("Could not authenticate: #{e}")
  end

  begin
    prospects = client.prospects.query(:list_id => 613, :sort_by => "last_activity_at")
    logger.info("Found #{prospects["total_results"]} Prospects")
  rescue f
    logger.info("Could not get prospects: #{f}")
  end
  
  signups = email_grab(prospects)
  signups
end