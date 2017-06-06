require 'ruby-pardot'
require 'logger'
require_relative 'services'

puts "Started"
logger = Logger.new("#{File.dirname(__FILE__)}/etc/log.log", 0, 100 * 1024 * 1024)
logger.level = Logger::DEBUG

puts recent_newsletter_list

logger.info("End of run -----------------------------")