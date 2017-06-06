require 'ruby-pardot'
require 'logger'
require_relative 'services'

puts "Started"
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

# For testing that this thing works
prospects = client.prospects.query(:list_id => 613, :sort_by => "last_activity_at")

puts prospects["total_results"] # number of prospects found

prospects["prospect"].each do |prospect|
  puts prospect["email"]
end

logger.info("End of run -----------------------------")