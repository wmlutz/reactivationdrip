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
logger.info("Woodies grab class = #{woodies.class}")
blacklist = []

puts "Checking Pardot newsletter list to woodies list #{DateTime.now}"
blacklist << ret_common(news_list, woodies)
puts "Checking recent SFDC list to woodies list #{DateTime.now}"
blacklist << ret_common(recent_SFDC, woodies)

blacklist.flatten!.uniq!

logger.info("woodies length: #{woodies.length}")
logger.info("news_list length: #{news_list.length}")
logger.info("Blacklist length: #{blacklist.length}")
logger.info("blacklist: #{blacklist}")

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
