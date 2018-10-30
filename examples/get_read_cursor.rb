require_relative '../lib/chatkit'

chatkit = Chatkit::Client.new({
  instance_locator: 'v1:us1:some-instance-id',
  key: 'the-id-bit:the-secret-bit'
})

p chatkit.get_read_cursor({
  user_id: "ham",
  room_id: "123"
})
