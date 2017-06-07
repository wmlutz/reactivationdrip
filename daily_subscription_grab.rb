require 'ruby-pardot'
require 'logger'
require_relative 'services_daily'

puts "Started"
logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
logger.level = Logger::DEBUG
logger.info("Beginning of run ----------------")

# gets the most recent newsletter list
news_list = newsletter_list

woodies = grab_woodies
blacklist = []

news_list.each do |prospect|
  blacklist << prospect unless woodies.grep(/#{prospect}/).empty?
end

puts blacklist
puts "Blacklist length: #{blacklist.length}"
logger.info("Blacklist length: #{blacklist.length}")
logger.info("End of run -----------------------------")