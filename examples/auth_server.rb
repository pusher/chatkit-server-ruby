require 'sinatra'
require 'json'
require 'cgi'
require_relative '../lib/chatkit'

# Get these from the Dashbaord
chatkit = Chatkit::Client.new({
  instance_locator: 'your:instance:locator',
  key: 'your:key'
})

post '/auth' do
  auth_data = chatkit.authenticate_with_request(
    request,
    { user_id: 'your-user-id' }
  )
  [
    auth_data.status,
    auth_data.headers,
    auth_data.body.to_json
  ]
end
