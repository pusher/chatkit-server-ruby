require_relative '../lib/chatkit'

chatkit = Chatkit::Client.new({
  instance_locator: "v1:us1:some-instance-id",
  key: "the-id-bit:the-secret-bit"
})

p chatkit.create_global_role(
	"mcflurry",
	[Chatkit::CREATE_MESSAGE, Chatkit::LEAVE_ROOM, Chatkit::ADD_ROOM_MEMBER]
)
