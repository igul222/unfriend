require 'rubygems'
require 'gmail'
require 'koala'

##########################
# Facebook Unfriend Finder
# By Ishaan Gulrajani
# USAGE:
# Fill in your Gmail credentials below. Create a new FB app
# at developers.facebook.com and add localhost as a domain.
# Fill in your app's ID and secret below. Install the 
# ruby-gmail and koala gems. Run! When prompted, go to the
# given URL to login with Facebook. When redirected to a 
# nonexistent page (localhost), copy the code in the URL and 
# paste it where prompted. You'll also need to create an 
# FBFriends label and retroactively filter all messages that
# have the words ("you as a friend on Facebook" OR 
# "you as a friend on Facebook") into that label.

user = 'example@gmail.com'
pass = 'some_password'
fb_appid = '012345678912345'
fb_secret = 'qwertyuiopqwertyuiopqwertyuiopqw'


# get current friends list from Facebook
oauth = Koala::Facebook::OAuth.new(fb_appid, 
  fb_secret, 
  'http://localhost/')

puts "Authenticate with URL: #{oauth.url_for_oauth_code}"
print "Copy/paste oauth access code from redirect URL here: "
code = gets.strip
access_token = oauth.get_access_token(code)
graph = Koala::Facebook::API.new(access_token)
friends = graph.get_connections("me", "friends")
current_friends = friends.map {|friend| friend["name"]}

puts "Found #{current_friends.count} current friends; searching for old friends..."

# get old friends list from Gmail
old_friends = []
regexes = [
  /(.+) wants to be friends on Facebook/,
  /(.+) added you as a friend on Facebook/,
  /(.+) confirmed you as a friend on Facebook/
  ]
gmail = Gmail.new(user, pass)
gmail.mailbox("FBFriends").emails.each do |email|
  subject = email.subject.to_s
  for regex in regexes
    if regex =~ subject
      old_friends << subject.match(regex)[1].to_s
    end
  end
end

# remove duplicate items in array
old_friends = old_friends & old_friends

puts "Found #{old_friends.count} old friends."
puts "Lost friends:"

puts old_friends - current_friends
