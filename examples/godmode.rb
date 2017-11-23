require_relative '../lib/chatkit'

chatkit = Chatkit::Client.new({
  instance: "v1:api-ceres:auth-example-app-1",
  key: "the-id-bit:the-secret-bit"
})

p chatkit.create_global_role(
	"godmode",
	["join_room", "leave_room", "add_room_member", "remove_room_member", "create_room", "delete_room", "update_room", "add_message", "create_typing_event", "subscribe_presence", "update_user", "get_room_messages", "get_user", "get_room", "get_user_rooms"]
)

p chatkit.assign_global_role_to_user("user", "godmode")
