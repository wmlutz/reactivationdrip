require 'logger'

def grab_salesforce_config
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/weekly.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  config = Hash.new

  logger.info('getting config file')
  open "#{File.dirname(__FILE__)}/etc/salesforce.conf" do |config_file|
    config_file.each_line do |line|
      unless line.chomp.empty? || line =~ /^#/
        username, pass, sec, client_id, client_sec = line.split ','
        config = { username: username,
                   password: pass,
                   security_token: sec,
                   client_id: client_id,
                   client_secret: client_sec
                 }
      end
    end
  end
  logger.info("got config for #{config['user_name']}")
  config
end

# Takes 4 emails, returns one
def flat_email(emails)
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/weekly.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  logger.info("Running flat_email on #{emails}")
  emails.each do |email|
    # logger.level("trying #{email}")
    return email unless email.nil?
  end
  return "No Email Found"
end

# Converts Restforce Collection object to hash
def arr_hasher(sfdcObj)
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/weekly.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  logger.info("Starting array hasher")
  arr = Array.new
  sfdcObj.each do |line|
    arr << { email: flat_email([line['MKT_Personal_Email__c'], line['email'], line['TR1__Work_Email__c'], line['TR1__Secondary_Email__c']]),
             first_name: line['FirstName'],
             last_name: line['LastName'],
             status: "ACTIVE",
             tags: "#FROMWKLYSCRPT"
           }
    end
    logger.info("Finished array hasher #{arr}")
    arr
end

# gets the contacts from SFDC
def grab_SFDC_contacts
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/weekly.log", 0, 100 * 1024 * 1024)
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
    rawContacts = client.query("SELECT FirstName,LastName,email,TR1__Work_Email__c,TR1__Secondary_Email__c,MKT_Personal_Email__c,Last_Activity_Date__c FROM contact WHERE Last_Activity_Date__c < N_DAYS_AGO:120 AND Last_Activity_Date__c > N_DAYS_AGO:128 ORDER BY Last_Activity_Date__c ASC")
  rescue h
    logger.info("Failed to grab query: #{h}")
  end
  logger.info("Got #{rawContacts.length} rawContacts.")
  logger.info("grabbed rawContacts: #{rawContacts}")

  # converting raw contacts into a array of hashes
  contacts = arr_hasher(rawContacts)

  contacts
end

def hashify(prospects)
  return {
    campaign: {
      campaign_id: 44919
    },
    update: 'true',
    prospects: prospects
  }
end