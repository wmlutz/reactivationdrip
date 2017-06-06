require 'ruby-pardot'
require 'logger'
require_relative 'services'

puts "Started"
logger = Logger.new("#{File.dirname(__FILE__)}/etc/log.log", 0, 100 * 1024 * 1024)
logger.level = Logger::DEBUG

# turn on when ready to actuall do api calls from pardot
# news_list = recent_newsletter_list

puts grab_woodpecker_config

logger.info("End of run -----------------------------")