require_relative '../lib/chatkit'

chatkit = Chatkit::Client.new({
  instance: "v1:api-deneb:auth-example-app-1",
  key: "the-id-bit:the-secret-bit"
})

p chatkit.authenticate({ grant_type: "client_credentials" }, "testymctest")