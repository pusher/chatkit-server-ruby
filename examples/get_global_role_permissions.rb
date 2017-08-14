require_relative '../lib/chatkit'

chatkit = Chatkit::Client.new({
  instance: "v1:api-deneb:auth-example-app-1",
  key: "the-id-bit:the-secret-bit"
})

p chatkit.get_permissions_for_global_role("mcflurry")
