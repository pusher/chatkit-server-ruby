require_relative '../lib/chatkit'

chatkit = Chatkit::Client.new({
  instance: "v1:api-ceres:auth-example-app-1",
  key: "the-id-bit:the-secret-bit"
})

p chatkit.assign_room_role_to_user("mcflurry", "adminzz", 123)