require_relative '../lib/chatkit'

chatkit = Chatkit::Client.new({
  instance_locator: "v1:us1:some-instance-id",
  key: "the-id-bit:the-secret-bit"
})

# p chatkit.create_room({
#   name: "a new room",
#   creator_id: "ham",
#   private: true,
#   user_ids: ['sarah', 'bill']
# })

p chatkit.create_room({
  name: "a new room",
  creator_id: "ham"
})
