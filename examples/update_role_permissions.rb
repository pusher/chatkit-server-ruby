require_relative '../lib/chatkit'

chatkit = Chatkit::Client.new({
  instance_locator: "v1:us1:some-instance-id",
  key: "the-id-bit:the-secret-bit"
})

p chatkit.update_role_permissions("default", "global", ["cursors:read:get"], ["cursors:read:set"])
