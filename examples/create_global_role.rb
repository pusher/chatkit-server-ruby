require_relative '../lib/chatkit'

chatkit = Chatkit::Client.new({
  instance: "v1:api-deneb:auth-example-app-1",
  key: "the-id-bit:the-secret-bit"
})

p chatkit.create_global_role(
	"mcflurry",
	[Chatkit::CREATE_MESSAGE, Chatkit::LEAVE_ROOM, Chatkit::ADD_ROOM_MEMBER]
)
