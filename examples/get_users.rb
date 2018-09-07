require_relative '../lib/chatkit'

chatkit = Chatkit::Client.new({
  instance_locator: "v1:us1:some-instance-id",
  key: "the-id-bit:the-secret-bit"
})

# p chatkit.get_users({
#   from_ts: '2018-08-14T15:42:19Z',
#   limit: 2
# })
p chatkit.get_users()
