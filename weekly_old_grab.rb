require 'restforce'
require 'logger'
require_relative 'weekly_services'

logger = Logger.new("#{File.dirname(__FILE__)}/etc/weekly.log", 0, 100 * 1024 * 1024)
logger.level = Logger::DEBUG

# Authenticate Salesforce connection
# client = Restforce.new(username: 'foo',
#                        password: 'bar',
#                        security_token: 'security token',
#                        client_id: 'client_id',
#                        client_secret: 'client_secret',
#                        api_version: '38.0')
# Get the contacts between 120 and 127 days since last activity
# format for woodpecker
# send that list to woodpecker