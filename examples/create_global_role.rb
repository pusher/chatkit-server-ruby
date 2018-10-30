require_relative '../lib/chatkit'

chatkit = Chatkit::Client.new({
  instance_locator: "v1:us1:some-instance-id",
  key: "the-id-bit:the-secret-bit"
})

p chatkit.create_global_role({
	name: "admin",
	permissions: ["cursors:read:set", "cursors:read:get"]
})
