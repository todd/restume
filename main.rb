require 'rubygems'
require 'bundler/setup'
require 'resolv'
require 'yaml'
require 'net/smtp'

Bundler.require

# Public: Display 'About' and API Docs
#
# Returns: the index.html file.
get '/' do
  # Index/Howto Content goes here
  File.read(File.join('public', 'index.html'))
end

# Public: Display a high-level overview of the resume
#
# Returns: JSON object of resume's high-level overview
get '/resume' do
  # Returns high-level of resume as JSON
  resume = YAML.load(File.open('resume.yml'))

  # We only want to return high-level information
  # about experience and education - detail can be seen
  # in education and experience resources
  education = []
  experience = []
 
  # Build list basic schooling information
  for school in resume['education']
    education << {'name' => school['name'], 'grad-date' => school['grad-date']}
  end

  # Build list of basic job experience
  for job in resume['experience']
    experience << {
      'title' => job['title'], 
      'organization' => job['organization'], 
      'period' => job['period']
    }
  end

  # Build response
  response = {
    'name' => resume['name'],
    'last-updated' => resume['last-updated'],
    'contact' => resume['contact'],
    'education' => education,
    'experience' => experience,
    'extra-curricular' => resume['extra-curricular'],
    'technical-skills' => resume['technical-skills'],
    'interests' => resume['interests']
  }

  # Send response
  status 200
  body(response.to_json)
end

# Public: Display only the education information from the resume.
#
# Returns: JSON object of education information.
get '/resume/education' do
  # Return educational history as JSON
  education = YAML.load(File.open('resume.yml'))['education']
  status 200
  body(education.to_json)
end

# Public: Display information about a specific educational institution
#         from the resume.
#
# Returns: JSON object of specific education information.
get '/resume/education/:id' do
  # Cast id to integer
  id = params[:id].to_i
  # Load education data
  # id - 1 so we're not zero-based on our indices
  school = YAML.load(File.open('resume.yml'))['education'][id - 1]
  if school.nil? then
    status 404
  # Ruby's negative indices freak me out.
  # In light of this, throwing a 418 seems appropriate.
  elsif id < 1 then
    status 418
  else
    status 200
    body(school.to_json)
  end
end

# Public: Display only the experience information from the resume.
#
# Returns: JSON object of job experiences.
get '/resume/experience' do
  experience = YAML.load(File.open('resume.yml'))['experience']
  status 200
  body(experience.to_json)
end

# Public: Display information about a specific educational institution
#         from the resume.
#
# Returns: JSON object of a specific job experience.
get '/resume/experience/:id' do
  id = params[:id].to_i
  # See rationale for id - 1 in /resume/education/:id comments
  job = YAML.load(File.open('resume.yml'))['experience'][id - 1]
  if job.nil? then
    status 404
  # See rationale for returning 418 in /resume/education/:id comments
  elsif id < 1 then
    status 418
  else
    status 200
    body(job.to_json)
  end
end

# Public: Display the technical skills information from the resume.
#
# Returns: JSON object of technical skills information.
get '/resume/skills' do
  skills = YAML.load(File.open('resume.yml'))['technical-skills']
  status 200
  body(skills.to_json)
end

# Public: Display the extra-curricular activities information from the resume.
#
# Returns: JSON object of activities information.
get '/resume/activities' do
  activities = YAML.load(File.open('resume.yml'))['extra-curricular']
  status 200
  body(activities.to_json)
end

# Public: Display the interests information from the resume.
#
# Returns: JSON object of interest information.
get '/resume/interests' do
  interests = YAML.load(File.open('resume.yml'))['interests']
  status 200
  body(interests.to_json)
end

# Public: We don't want a 'Not Found' message if someone tries
#         to access this resource with GET. Raise a 405.
#
# Returns: A 405 HTTP status.
get '/contact' do
  status 405
end

# Public: Send Todd an email if you're impressed by his resume
#         and want to offer him a sweet gig.
#
# Returns: A Status 400 response if not all data is sent or
#          or the email address is not valid. A 200 status
#          if everything went right.
post '/contact' do
  # Takes data in as JSON
  data = JSON.parse(request.body.string)
  # If no data, missing data, or invalid email address, raise a 400
  if data.nil? or !data.has_key?('name') or !data.has_key?('email') or 
      !data.has_key?('body') or !valid_email(data['email']) then
    status 400
  else
    server = 'localhost'
    address =  'noreply@dd0t.com'
    address_alias = 'RESTume Contact'
    to = 'todd.bealmear@gmail.com'
    from = data['email']
    from_alias = data['name']
    body = data['body']
    
    # The message to send
    msg = <<END_OF_MESSAGE
From: #{address_alias} <#{address}>
Reply-To: #{from_alias} <#{from}>
To: #{to}
Subject: New RESTume Contact
#{body}
END_OF_MESSAGE
    
    # Send it, yo!
    Net::SMTP.start(server) do |smtp|
      smtp.send_message msg, address, to
    end
    status 200
    puts "**** New contact email sent"
  end
end

# Public: Check to see if an email is valid
#
# Since there's no catch-all way to verify an email
# address through regex, we'll just check to make sure
# that the domain the user is using exists and has an MX
# record.
#
# Returns: true if address is valid, false if not.
def valid_email(email)
  domain = email.match(/\@(.+)/)[1]
  Resolv::DNS.open do |dns|
    @mx = dns.getresources(domain, Resolv::DNS::Resource::IN::MX)
  end
  @mx.size > 0 ? true : false
end
