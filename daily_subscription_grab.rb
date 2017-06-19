require 'ruby-pardot'
require 'logger'
require_relative 'services_daily'

puts "Started Run"
logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
logger.level = Logger::DEBUG

logger.info("Beginning of run ----------------")
puts "Getting pardot newsletter list #{DateTime.now}"
news_list = grab_newsletter_list # gets the most recent newsletter list
puts "Getting woodies list #{DateTime.now}"
woodies = grab_woodies # Gets the woodies
puts "Getting SFDC recents list #{DateTime.now}"
recent_SFDC = grab_recent_SFDCs
blacklist = []

puts "Checking Pardot newsletter list to woodies list #{DateTime.now}"
news_list.each do |prospect| # checks each newsltr entry for being in woodpecker
  blacklist << prospect unless woodies.select { |w| w['email'].downcase! == prospect.downcase! }.empty?
end

puts "Checking recent SFDC list to woodies list #{DateTime.now}"
recent_SFDC.each do |email| # checks recent activity SFDC contacts for being in wp
  blacklist << email unless woodies.select { |y| y['email'].downcase! == email.downcase! }.empty?
end

logger.info("blacklist: #{blacklist}")
logger.info("Blacklist length: #{blacklist.length}")

puts "Sending blacklist to supression #{DateTime.now}"
if blacklist.length > 0
  logger.info("Sending #{blacklist.length} entries to blacklist")
  payload = turn_into_JSONHashArray(blacklist) # formats the new blacklist additions for RESTAPI
  put_into_blacklist(payload) # sends formated blacklist to Woodpecker
else
  logger.info("Didn't send any, blacklist length was #{blacklist.length}")
end

logger.info("End of run ----------------")
puts "End of Run"
