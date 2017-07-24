require_relative '../lib/chatkit'

chatkit = Chatkit::Client.new({
  instance: "v1:api-ceres:auth-example-app-1",
  key: "the-id-bit:the-secret-bit"
})

p chatkit.create_room_role(
	"adminzz",
	["add_message", "leave_room", "add_room_member"]
)
