require_relative '../lib/chatkit'

chatkit = Chatkit::Client.new({
  instance_locator: 'v1:us1:some-instance-id',
  key: 'the-id-bit:the-secret-bit'
})

auth_data = chatkit.authenticate({
  user_id: 'testymctest' #,
  # auth_payload: { grant_type: 'client_credentials' }
})

p auth_data

p auth_data.body
