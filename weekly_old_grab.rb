require 'restforce'
require 'logger'
require_relative 'services_weekly'

logger = Logger.new("#{File.dirname(__FILE__)}/etc/weekly.log", 0, 100 * 1024 * 1024)
logger.level = Logger::DEBUG

puts "Starting . . ."
# Get contacts from SFDC
contacts = grab_SFDC_contacts
# logger.info("Contacts: #{contacts}")

# format for woodpecker
# send that list to woodpecker

puts "And we're done."