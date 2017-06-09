require 'ruby-pardot'
require 'logger'
require_relative 'services_daily'

puts "Started Run"
logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
logger.level = Logger::DEBUG

logger.info("Beginning of run ----------------")

news_list = grab_newsletter_list # gets the most recent newsletter list
woodies = grab_woodies # Gets the woodies
# Commented out for testing
# recent_SFDC = grab_recent_SFDCs
blacklist = []

news_list.each do |prospect| # checks each newsltr entry for being in woodpecker
  blacklist << prospect unless woodies.select { |w| w['email'] == prospect }.empty?
end

# XXXXX Commented out for testing
# recent_SFDC do |email| # checks recent activity SFDC contacts for being in wp
#   blacklist << email unless woodies.select { |y| y['email'] == email }.empty?
# end

logger.info("blacklist: #{blacklist}")
logger.info("Blacklist length: #{blacklist.length}")

payload = turn_into_JSONHashArray(blacklist) # formats the new blacklist additions for RESTAPI
put_into_blacklist(payload) # sends formated blacklist to Woodpecker

logger.info("End of run ----------------")
puts "End of Run"