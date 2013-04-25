require "net/http" 
require 'net-http-spy'


#require 'unroller'
#Unroller::trace

puts "usage of oAuth service...\n" 

proxy_addr = 'web-proxy.houston.hp.com'
proxy_port = 8080

client_id = 'b514b1b2124f11e2b8cb68b599f571ed'
client_secret = 'bf6e0866124f11e2b0a868b599f571ed'

username = 'oauth-1873181259535763@snapfish.com'
password = 'oauth-1873181259535763 '

#Net::HTTP.http_logger_options = {:verbose => true}

uri = URI.parse("https://oauth.qa.snapfish.com")
http = Net::HTTP.new(uri.host, uri.port, proxy_addr, proxy_port)
http.use_ssl = true 
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
req = Net::HTTP::Post.new '/auth/access_token'
#req.body = multipart_data
req.content_type = 'application/x-www-form-urlencoded'
req.set_form_data( :grant_type => 'password', :username => username, :password => password,:client_id => client_id,    :client_secret => client_secret)
#req = Net::HTTP::Get.new '/'
res = http.request req
puts res.body
