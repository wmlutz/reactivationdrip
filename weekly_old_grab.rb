require 'restforce'
require 'logger'
require_relative 'services_weekly'

logger = Logger.new("#{File.dirname(__FILE__)}/etc/weekly.log", 0, 100 * 1024 * 1024)
logger.level = Logger::DEBUG

puts "Starting . . ."
# Get contacts from SFDC
logger.info('starting the SFDC Contact grab')
prospects = grab_SFDC_contacts

# formats contacts for woodpecker
logger.info('Starting the SFDC Hashify grab')
logger.info("Testing hashify on first el: #{hashify([prospects[0]])}")

prehash = hashify(prospects)
puts prehash

# send that list to woodpecker

puts "And we're done."