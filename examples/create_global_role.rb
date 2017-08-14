require_relative '../lib/chatkit'

chatkit = Chatkit::Client.new({
  instance: "v1:api-deneb:auth-example-app-1",
  key: "the-id-bit:the-secret-bit"
})

p chatkit.create_global_role(
	"mcflurry",
	["add_message", "leave_room", "add_room_member"]
)
