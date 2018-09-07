require_relative '../lib/chatkit'

chatkit = Chatkit::Client.new({
  instance_locator: 'v1:us1:some-instance-id',
  key: 'the-id-bit:the-secret-bit'
})

user_id = "ham"

p chatkit.cursors_request({
  method: 'GET',
  path: "/cursors/0/users/#{user_id}",
  headers: {
    "Content-Type": "application/json"
  },
  jwt: chatkit.generate_su_token
})
