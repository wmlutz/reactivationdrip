require 'restforce'
require 'logger'
require_relative 'weekly_services'

logger = Logger.new("#{File.dirname(__FILE__)}/etc/weekly.log", 0, 100 * 1024 * 1024)
logger.level = Logger::DEBUG

# Get Salesforce config info
config = grab_salesforce_config

# Authenticate Salesforce connection
begin
  client = Restforce.new(username: config[:username],
                         password: config[:password],
                         security_token: config[:security_token],
                         client_id: config[:client_id],
                         client_secret: config[:client_secret],
                         api_version: '38.0')
  logger.info("Trying describe: #{client.describe('Account')}")
rescue g
  logger.info("failed to authenticate SFDC: #{g}")
end

# Get the contacts between 120 and 127 days since last activity
# format for woodpecker
# send that list to woodpecker