require 'restforce'
require 'logger'
require_relative 'services_weekly'

logger = Logger.new("#{File.dirname(__FILE__)}/etc/weekly.log", 0, 100 * 1024 * 1024)
logger.level = Logger::DEBUG

puts 'Starting Weekly. . .'
logger.info('Starting weekly ------------')

# Get contacts from SFDC
logger.info('starting the SFDC Contact grab')
prospects = grab_SFDC_contacts
# puts "prospects class #{prospects.class}"

can_prospects = prospects[:candidates]
cli_prospects = prospects[:clients]

# puts "can prospects class #{can_prospects.class}"
# puts "cli prospects class #{cli_prospects.class}"

# formats contacts for woodpecker
logger.info('Starting the SFDC Hashify grab')
logger.info("Number of candidates: #{can_prospects.length}")
logger.info("Number of clients: #{cli_prospects.length}")

payload_can = hashify(can_prospects, 44919)
payload_cli = hashify(cli_prospects, 45127)

# send that list to woodpecker
send_to_campaign(payload_can)
send_to_campaign(payload_cli)

puts "And we're done."
logger.info('End of weekly ------------')
