require 'json'
require 'uri'
require 'net/http'
require 'logger'
require_relative 'api_services'

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

# Works through client and candidate status logic
def c_or_c(client, candidate)
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/weekly.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  x = case client
      when 'Wrong Contact', 'Not Applicable', 'Employee-Placement', 'LEFT'
        'Candidate'
      when 'Hiring Manager', 'Human Resources', 'Interviewer', 'M.A.N.'
        'Client'
      when 'Target'
        case candidate
        when 'Prospect', 'Not Applicable'
          'Client'
        else
          'Candidate'
        end
      else
        'Client'
      end

  logger.info("For client val of '#{client}' and candidate of '#{candidate}', returning '#{x}'")
  x
end

def co_type_snip(cust_type)
  return case cust_type
         when 'ISV'
           'Software Vendor'
         when 'Consulting Partner'
           'Consulting Partner'
         else
           'Customer'
         end
end

# Converts Restforce Collection object to hash
def arr_hasher(sfdcObj)
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/weekly.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  logger.info("Starting array hasher")
  cli_arr = Array.new
  can_arr = Array.new

  sfdcObj.each do |line|
    contact_type = c_or_c(line['TR1__Client_Status__c'], line['TR1__Candidate_Status__c'])
    co_type = co_type_snip(line['Account.Customer_Type__c'])
    case contact_type
    when 'Candidate'
      can_arr << { email: flat_email([line['MKT_Personal_Email__c'], line['email'], line['TR1__Work_Email__c'], line['TR1__Secondary_Email__c']]),
                   first_name: line['FirstName'],
                   last_name: line['LastName'],
                   snipet1: contact_type,
                   company: line['Account.Name'],
                   snipet2: co_type,
                   snipet3: line['TR1__Function__c'],
                   status: "ACTIVE",
                   tags: "#FROMWKLYSCRPT" }
    else
       cli_arr << { email: flat_email([line['MKT_Personal_Email__c'], line['email'], line['TR1__Work_Email__c'], line['TR1__Secondary_Email__c']]),
                    first_name: line['FirstName'],
                    last_name: line['LastName'],
                    snipet1: contact_type,
                    company: line['Account.Name'],
                    snipet2: co_type,
                    snipet3: line['TR1__Function__c'],
                    status: "ACTIVE",
                    tags: "#FROMWKLYSCRPT" }
    end
  end
  logger.info("Finished array hasher #{arr}")
  return { clients: cli_arr, candidates: can_arr }
end

# gets the contacts from SFDC
def grab_SFDC_contacts
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/weekly.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  # # Get Salesforce config info
  # config = grab_salesforce_config
  #
  # # Authenticate Salesforce connection
  # begin
  #   client = Restforce.new(username: config[:username],
  #                          password: config[:password],
  #                          security_token: config[:security_token],
  #                          client_id: config[:client_id],
  #                          client_secret: config[:client_secret],
  #                          api_version: '38.0')
  # rescue g
  #   logger.info("failed to authenticate SFDC: #{g}")
  # end
  #
  # # Get the contacts between 120 and 127 days since last activity
  # begin
  #   rawContacts = client.query("SELECT FirstName,LastName,email,TR1__Work_Email__c,TR1__Secondary_Email__c,Account.Customer_Type__c,Account.Name,MKT_Personal_Email__c,TR1__Client_Status__c,TR1__Function__c,TR1__Candidate_Status__c,Last_Activity_Date__c FROM contact WHERE Last_Activity_Date__c < N_DAYS_AGO:120 AND Last_Activity_Date__c > N_DAYS_AGO:128 ORDER BY Last_Activity_Date__c ASC")
  # rescue h
  #   logger.info("Failed to grab query: #{h}")
  # end
  # logger.info("Got #{rawContacts.length} rawContacts.")
  # logger.info("grabbed rawContacts: #{rawContacts}")
  #
  # # converting raw contacts into a array of hashes
  # contacts = arr_hasher(rawContacts)
 # contacts
  # Commenting everything above for testing purposes
  contacts = [{:email => "test1@gmail.com", :first_name => "Winter", :last_name => "Bucky", :status => "ACTIVE", :tags => "#FROMWKLYSCRPT"
              }, {:email => "test2@here.com", :first_name => "Steve", :last_name => "Rogers", :status => "ACTIVE", :tags => "#FROMWKLYSCRPT"
              }, {:email => "test3@mail.com", :first_name => "Tony", :last_name => "Stark", :status => "ACTIVE", :tags => "#FROMWKLYSCRPT"

              }]
              contacts
end

def hashify(prospects, camp_id)
  return {
    campaign: {
      campaign_id: camp_id
    },
    update: 'true',
    prospects: prospects
  }
end

# send new prospects to WP Campaign
def send_to_campaign(payload)
  logger = Logger.new("#{File.dirname(__FILE__)}/etc/weekly.log", 0, 100 * 1024 * 1024)
  logger.level = Logger::DEBUG

  key = grab_woodpecker_config[0]
  pass = "X"

  uri = URI("https://api.woodpecker.co/rest/v1/add_prospects_campaign")
  header = {'Content-Type' => 'text/json'}

  begin
    Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|

      req = Net::HTTP::Post.new(uri.request_uri, header)
      req.body = payload.to_json
      req.basic_auth key, pass

      # Send request, get response
      res = http.request req

      logger.info("Got response of: #{res}")
      logger.info("Got response body of: #{res.body}")
      puts res
      puts res.body
    end
  rescue => j
    logger.info("Rescuing: #{j}")
    logger.info("Backtrace: #{j.backtrace}")
    puts "Rescue: #{j}"
  end
end