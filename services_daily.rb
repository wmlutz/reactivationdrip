require 'ruby-pardot'
require 'logger'
require 'json'
require 'uri'
require 'net/http'
require_relative 'api_services'

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

# Gets the list of the most recent newsletter from Pardot
def grab_newsletter_list
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
  #   logger.info("Found #{prospects["total_results"]} Newsletter subscribers")
  # rescue f
  #   logger.info("Could not get newsletter subscribers: #{f} backtrace #{f.backtrace}")
  # end
  #
  # signups = email_grab(prospects) # sends back the email element
  # signups

  # All above commented out for testing
  return ["evan@twentypine.com", "max@twentypine.com", "wlutz@twentypine.com", "test@gmail.com", "testing@gmail.com"]
end

# Sends payload to woodpecker for suprression
def put_into_blacklist(payload)
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  key = grab_woodpecker_config[0]
  pass = "X"

  uri = URI("https://api.woodpecker.co/rest/v1/stop_followups")
  header = {'Content-Type' => 'text/json'}

  logger.info("Starting HTTP with the following uri: #{uri} uri.host:#{uri.host} uri.port: #{uri.port}")
  Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|

    req = Net::HTTP::Post.new(uri.request_uri, header)
    req.basic_auth key, pass

    payload.each do |entry|
      sleep(1)
      req.body = entry.to_json
      logger.info("Setting req.body to #{req.body}")
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

# Grabs the woodpecker full propsect list
def grab_woodies()
  # logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
  # logger.level = Logger::DEBUG
  #
  # key = grab_woodpecker_config[0]
  # pass = 'X'
  # woodies = []
  # pullrun = []
  # num = 1
  #
  # loop do # gets every page of wp prospects until no more left
  #   uri = URI("https://api.woodpecker.co/rest/v1/prospects?page=#{num}&per_page=500")
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

def grab_recent_SFDCs
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  # Get Salesforce config info
  config = grab_salesforce_config

  # Authenticate Salesforce connection
  begin
    client = Restforce.new(username: config[:username],
                           password: config[:password],
                           security_token: config[:security_token],
                           client_id: config[:client_id],
                           client_secret: config[:client_secret],
                           api_version: '38.0')
  rescue g
    logger.info("failed to authenticate SFDC: #{g}")
  end

  # Get the contacts between 120 and 127 days since last activity
  begin
    rawEmails = client.query("SELECT email,TR1__Work_Email__c,TR1__Secondary_Email__c,MKT_Personal_Email__c,Last_Activity_Date__c FROM contact WHERE Last_Activity_Date__c > N_DAYS_AGO:9 AND Last_Activity_Date__c < N_DAYS_AGO:0")
  rescue h
    logger.info("Failed to grab query: #{h}")
  end
  logger.info("Got #{rawEmails.length} contacts and their emails.")
  # logger.info("grabbed rawEmails: #{rawEmails}")

  emails = Array.new

  # converting SFDC Obj to array of emails to be suppressed
  rawEmails.each do |line|
    emails << line['email'] unless line['email'].nil?
    emails << line['TR1__Work_Email__c'] unless line['TR1__Work_Email__c'].nil?
    emails << line['TR1__Secondary_Email__c'] unless line['TR1__Secondary_Email__c'].nil?
    emails << line['MKT_Personal_Email__c'] unless line['MKT_Personal_Email__c'].nil?
  end
  emails
end
