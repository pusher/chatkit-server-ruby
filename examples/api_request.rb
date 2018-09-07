require_relative '../lib/chatkit'

chatkit = Chatkit::Client.new({
  instance_locator: 'v1:us1:some-instance-id',
  key: 'the-id-bit:the-secret-bit'
})

p chatkit.api_request({
  method: 'GET',
  path: "/rooms",
  headers: {
    "Content-Type": "application/json"
  },
  jwt: chatkit.generate_su_token
})
