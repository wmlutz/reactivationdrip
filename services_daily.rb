require 'ruby-pardot'
require 'logger'
require 'json'
require 'uri'
require 'net/http'
require 'restforce'
require_relative 'api_services'

# returns common elements from the arrays
def ret_common(arr_a, arr_b)
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG
  logger.info("array a class: #{arr_a.class}")
  logger.info("array b class: #{arr_b.class}")
  logger.info("array a first: #{arr_a[0]}")
  logger.info("array b first: #{arr_b[0]}")
  logger.info("array a first class: #{arr_a[0].class}")
  logger.info("array b first class: #{arr_b[0].class}")
  return arr_a & arr_b
end

# turns array into json formatted string for passing to woodpecker blacklist
def turn_into_JSONHashArray(arr)
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  jsonArr = Array.new

  arr.each do |row|
    jsonArr << { prospect: { email: row } }
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
    signups << prospect["email"]
  end
  logger.info("Got prospects signed up #{signups.length}")
  signups
end

# Gets the list of the most recent newsletter from Pardot
def grab_newsletter_list
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
  rescue StandardError => e
    logger.info("Could not authenticate: #{e}")
  end

  begin
    prospects = client.prospects.query(:list_id => 613, :sort_by => "last_activity_at")
    logger.info("Found #{prospects["total_results"]} Newsletter subscribers")
  rescue StandardError => f
    logger.info("Could not get newsletter subscribers: #{f} backtrace #{f.backtrace}")
  end

  signups = email_grab(prospects) # sends back the email element
  signups

  # Alternate commenting for testing
  # return ["evanl@twentypine.com", "maxl@twentypine.com", "wlutz@twentypine.com", "test@gmail.com", "testing@gmail.com"]
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
      rescue StandardError => j
        logger.info("Rescuing: #{j}")
        logger.info("Backtrace: #{j.backtrace}")
        puts "Rescue: #{j}"
      end
    end
  end
end

#grab woodies returns an array of hashes, this strips it down to just emails
def just_email(myArr)
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG
  emails = Array.new

  logger.info("Just_email starting array #{myArr[0]}")
  myArr.each do |i|
    # logger.info("i is #{i}")
    # logger.info("email element of i as clled is #{i[:email]}")
    emails << i['email']
  end
  logger.info("Ending array of #{emails[0]}")
  emails
end

# Grabs the woodpecker full propsect list
def grab_woodies()
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/daily.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  key = grab_woodpecker_config[0]
  pass = 'X'
  woodies = []
  pullrun = []
  num = 1

  loop do # gets every page of wp prospects until no more left
    uri = URI("https://api.woodpecker.co/rest/v1/prospects?page=#{num}&per_page=500")
    logger.info("grabbing from URI of #{uri}")
    begin
      Net::HTTP.start(uri.host, uri.port, :read_timeout => 500, :use_ssl => uri.scheme == 'https',
      :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Get.new uri.request_uri
      sleep(1)
      request.basic_auth key, pass
      response = http.request request # Net::HTTPResponse object

      pullrun = JSON.parse(response.body)
      logger.info("Grabbed #{pullrun.length} woodies")
      woodies.concat(pullrun)
    end
    rescue StandardError => m
      logger.info("Standard error #{m}")
      puts("Standard error #{m}")
    end
    break if pullrun.length < 500
    num = num + 1
  end
  logger.info("Grabbed #{woodies.length} Woodies in total")

  return just_email(woodies)
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
    client.authenticate!
  rescue StandardError => g
    logger.info("failed to authenticate SFDC: #{g}")
  end
  logger.info("Authenticated SFDC")

  # Get the contacts between 120 and 127 days since last activity
  begin
    rawEmails = client.query("SELECT email,TR1__Work_Email__c,TR1__Secondary_Email__c,MKT_Personal_Email__c,Last_Activity_Date__c FROM contact WHERE Last_Activity_Date__c > N_DAYS_AGO:9 AND Last_Activity_Date__c < N_DAYS_AGO:0")
  rescue StandardError => h
    logger.info("Failed to grab query: #{h}")
  end
  logger.info("Got #{rawEmails.length} contacts and their emails.")
  # logger.info("grabbed rawEmails: #{rawEmails}")

  emails = []

  # converting SFDC Obj to array of emails to be suppressed
  rawEmails.each do |line|
    emails << line['email'] unless line['email'].nil?
    emails << line['TR1__Work_Email__c'] unless line['TR1__Work_Email__c'].nil?
    emails << line['TR1__Secondary_Email__c'] unless line['TR1__Secondary_Email__c'].nil?
    emails << line['MKT_Personal_Email__c'] unless line['MKT_Personal_Email__c'].nil?
  end
  logger.info("Sending a total of #{emails.length} emails from SFDC")
  emails
end
