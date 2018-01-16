require_relative '../lib/chatkit'

chatkit = Chatkit::Client.new({
  instance_locator: "v1:us1:some-instance-id",
  key: "the-id-bit:the-secret-bit"
})

# FakeRequest and FakeRequestBody are used here to mimic Rack::Request

class FakeRequest
  def initialize
  end

  def body
    FakeRequestBody.new
  end
end

class FakeRequestBody
  def initialize
  end

  def read
    'grant_type=client_credentials'
  end
end

p chatkit.authenticate(FakeRequest.new, { user_id: "testymctest" })
