require 'ruby-pardot'
require 'logger'
require_relative 'services'

puts "Started"
logger = Logger.new("#{File.dirname(__FILE__)}/etc/log.log", 0, 100 * 1024 * 1024)
logger.level = Logger::DEBUG
logger.info("Beginning of run ----------------")

# turn on when ready to actuall do api calls from pardot
# news_list = recent_newsletter_list

# needs to be updated for put instead of get
# woodpecker_update(news_list)

logger.info("End of run -----------------------------")