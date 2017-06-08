require 'ruby-pardot'
require 'logger'
require 'json'
require 'uri'
require 'net/http'

# turns array into json formatted string for passing to woodpecker blacklist
def turn_JSON(arr)
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  jsonArr = Array.new

  arr.each do |row|
    jsonArr << "{'prospect':{'email':'#{row}'}}"
    logger.info("{'prospect':{'email':'#{row}'}}")
  end
  jsonArr
end

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
def newsletter_list
  # logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
  # logger.level = Logger::DEBUG
  #
  # # Starts by getting Pardot config
  # config = grab_pardot_config
  #
  # # Authenticate pardot connection
  # logger.info('Attempting authentication . . .')
  # begin
  #   client = Pardot::Client.new config[:user_email], config[:user_pass], config[:user_key]
  #   client.authenticate
  #   logger.info('Authentication successful')
  # rescue e
  #   logger.info("Could not authenticate: #{e}")
  # end
  #
  # begin
  #   prospects = client.prospects.query(:list_id => 613, :sort_by => "last_activity_at")
  #   logger.info("Found #{prospects["total_results"]} Prospects")
  # rescue f
  #   logger.info("Could not get prospects: #{f}")
  # end
  #
  # signups = email_grab(prospects)
  # signups

  # All above commented out for testing
  return ["evan@twentypine.com", "max@twentypine.com", "wlutz@twentypine.com", "test@gmail.com", "testing@gmail.com"]
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

# Will be where I put the actual blacklisting of contacts in Woodpecker
def put_into_blacklist(payload)
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  key = grab_woodpecker_config[0]
  pass = "X"

  uri = URI("https://api.woodpecker.co/rest/v1/stop_followups")
  header = {'Content-Type' => 'text/json'}


  Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|

    req = Net::HTTP::Post.new(uri.request_uri, header)
    req.basic_auth key, pass

    payload.each do |entry|
      sleep(1)
      req.body = entry.to_json
      begin
        res = http.request req

        logger.info("Got response of: #{res}")
        logger.info("Got response body of: #{res.body}")
      rescue => j
        logger.info("Rescuing: #{j}")
        logger.info("Backtrace: #{j.backtrace}")
        puts "Rescue: #{j}"
      end
    end
  end

end

# Grabs the woodpecker propsect list
def grab_woodies()
  # logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
  # logger.level = Logger::DEBUG
  #
  # key = grab_woodpecker_config[0]
  # pass = 'X'
  # woodies = []
  # pullrun = []
  # num = 1
  # loop do
  #   uri = URI("https://api.woodpecker.co/rest/v1/prospects?page=#{num}&per_page=500")
  #   puts "URI of #{uri}"
  #   logger.info("grabbing from URI of #{uri}")
  #   Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https',
  #     :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
  #     request = Net::HTTP::Get.new uri.request_uri
  #     sleep(1)
  #     request.basic_auth key, pass
  #     response = http.request request # Net::HTTPResponse object
  #
  #     pullrun = JSON.parse(response.body)
  #     puts "Grabbed #{pullrun.length} woodies"
  #     logger.info("Grabbed #{pullrun.length} woodies")
  #     woodies.concat(pullrun)
  #   end
  #   break if pullrun.length < 500
  #   num = num + 1
  # end
  # logger.info("Grabbed #{woodies.length} Woodies in total")
  # puts "End of grabbing woodies: #{woodies.length}"
  # woodies

  # XXXXXXX everything above commented out for testing
  return [{"id"=>14506062, "email"=>"test@gmail.com", "first_name"=>"Rocky", "last_name"=>"", "company"=>"Sofar Sounds", "industry"=>"", "website"=>"", "tags"=>"", "title"=>"", "phone"=>"", "address"=>"", "city"=>"", "state"=>"", "country"=>"", "last_contacted"=>"", "last replied"=>"", "updated"=>"2017-05-18T19:18:22+0200", "snipet1"=>"", "snipet2"=>"", "snipet3"=>"", "snipet4"=>"", "snippet5"=>"", "snippet6"=>"", "snippet7"=>"", "snippet8"=>"", "snippet9"=>"", "snippet10"=>"","snippet11"=>"", "snippet12"=>"", "snippet13"=>"", "snippet14"=>"", "snippet15"=>"", "status"=>"ACTIVE"},{"id"=>14506063, "email"=>"wlutz@twentypine.com", "first_name"=>"Mark", "last_name"=>"", "company"=>"Solstice Benefits", "industry"=>"", "website"=>"", "tags"=>"", "title"=>"", "phone"=>"", "address"=>"", "city"=>"", "state"=>"", "country"=>"", "last_contacted"=>"", "last replied"=>"", "updated"=>"2017-05-18T19:18:22+0200", "snipet1"=>"", "snipet2"=>"", "snipet3"=>"", "snipet4"=>"", "snippet5"=>"", "snippet6"=>"", "snippet7"=>"", "snippet8"=>"", "snippet9"=>"", "snippet10"=>"", "snippet11"=>"", "snippet12"=>"", "snippet13"=>"", "snippet14"=>"", "snippet15"=>"", "status"=>"ACTIVE"},{"id"=>14506064, "email"=>"william.meany.lutz@gmail.com", "first_name"=>"Katie", "last_name"=>"", "company"=>"SplashThat.com", "industry"=>"", "website"=>"", "tags"=>"", "title"=>"", "phone"=>"", "address"=>"", "city"=>"", "state"=>"", "country"=>"", "last_contacted"=>"", "last replied"=>"", "updated"=>"2017-05-18T19:18:22+0200", "snipet1"=>"", "snipet2"=>"", "snipet3"=>"", "snipet4"=>"", "snippet5"=>"", "snippet6"=>"", "snippet7"=>"", "snippet8"=>"", "snippet9"=>"", "snippet10"=>"", "snippet11"=>"", "snippet12"=>"", "snippet13"=>"", "snippet14"=>"", "snippet15"=>"", "status"=>"ACTIVE"}]

end
