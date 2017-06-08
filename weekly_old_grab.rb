require 'restforce'
require 'logger'
require_relative 'services_weekly'

logger = Logger.new("#{File.dirname(__FILE__)}/etc/weekly.log", 0, 100 * 1024 * 1024)
logger.level = Logger::DEBUG

puts 'Starting . . .'
# Get contacts from SFDC
logger.info('starting the SFDC Contact grab')
prospects = grab_SFDC_contacts
can_prospects = prospects['candidates']
cli_prospects = propsects['clients']

# formats contacts for woodpecker
logger.info('Starting the SFDC Hashify grab')
logger.info("Testing hashify on first el: #{hashify([prospects[0]])}")

payload_can = hashify(prospects, 44919)
payload_cli = hashify(prospects, 45127)

# send that list to woodpecker
send_to_campaign(payload_can)
send_to_campaign(payload_cli)

puts "And we're done."
