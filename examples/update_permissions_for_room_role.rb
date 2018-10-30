require_relative '../lib/chatkit'

chatkit = Chatkit::Client.new({
  instance_locator: "v1:us1:some-instance-id",
  key: "the-id-bit:the-secret-bit"
})

p chatkit.update_permissions_for_room_role({
  name: "adminzz",
  permissions_to_add: ["room:join"],
  permissions_to_remove: ["cursors:read:set"]
})
