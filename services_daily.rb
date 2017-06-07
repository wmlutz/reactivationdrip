require 'ruby-pardot'
require 'logger'
require 'json'
require 'uri'
require 'net/http'

# Gets the email from prospects list sent in from pardot
def email_grab(prospects)
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  signups = []
  prospects["prospect"].each do |prospect|
    logger.info("Getting #{prospect['email']} Prospect")
    signups << prospect["email"]
  end
  logger.info("Got signups #{signups}")
  signups
end

# Gets pardot configuration key and password data
def grab_pardot_config
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  config = Hash.new

  logger.info('getting config file')
  open "#{File.dirname(__FILE__)}/etc/pardot.conf" do |config_file|
    config_file.each_line do |line|
      unless line.chomp.empty? || line =~ /^#/
        email, pass, key = line.split ','
        config = { user_email: email,
                   user_pass: pass,
                   user_key: key }
      end
    end
  end
  logger.info("got config for #{config[:user_email]}")
  config
end

# Gets the list of the most recent newsletter from Pardot
def recent_newsletter_list
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  # Starts by getting Pardot config
  config = grab_pardot_config

  # Authenticate pardot connection
  logger.info('Attempting authentication . . .')
  begin
    client = Pardot::Client.new config[:user_email], config[:user_pass], config[:user_key]
    client.authenticate
    logger.info('Authentication successful')
  rescue e
    logger.info("Could not authenticate: #{e}")
  end

  begin
    prospects = client.prospects.query(:list_id => 613, :sort_by => "last_activity_at")
    logger.info("Found #{prospects["total_results"]} Prospects")
  rescue f
    logger.info("Could not get prospects: #{f}")
  end

  signups = email_grab(prospects)
  signups
end

# Gets the woodpecker configuration api key
def grab_woodpecker_config
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  key = ""

  logger.info('getting woodpecker config file')
  open "#{File.dirname(__FILE__)}/etc/woodpecker.conf" do |config_file|
    config_file.each_line do |line|
      unless line.chomp.empty? || line =~ /^#/
        key = line.split ','
      end
    end
  end
  logger.info("got key")
  key
end

# converts a string to a json object for woodpecker
# def wp_json(email)
#   json_to_go = {
#     "prospect":{
#       "email":email
#     }
#   }
# end

# Will be where I put the actual blacklisting of contacts in Woodpecker
def woodpecker_update(news_list)
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  key = grab_woodpecker_config[0]
  pass = "X"

  # news_list.each do |x|
  #   pros_json = wp_json(x)

  uri = URI("https://api.woodpecker.co/rest/v1/campaign_list")

  Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https',
    :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|

    request = Net::HTTP::Get.new uri.request_uri
    request.basic_auth key, pass

    response = http.request request # Net::HTTPResponse object

    puts response
    puts response.body
  end
end

# Grabs the woodpecker propsect list
def grab_woodies()
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  key = grab_woodpecker_config[0]
  pass = 'X'
  woodies = []
  pullrun = []
  num = 1
  loop do
    uri = URI("https://api.woodpecker.co/rest/v1/prospects?page=#{num}&per_page=500")
    puts "URI of #{uri}"
    logger.info("grabbing from URI of #{uri}")
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https',
      :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Get.new uri.request_uri
      sleep(1)
      request.basic_auth key, pass
      response = http.request request # Net::HTTPResponse object

      pullrun = JSON.parse(response.body)
      puts "Grabbed #{pullrun.length} woodies"
      logger.info("Grabbed #{pullrun.length} woodies")
      woodies << pullrun
    end
    break if pullrun.length < 500
    num = num + 1
  end
  puts woodies
  puts "End of grabbing woodies"
end
