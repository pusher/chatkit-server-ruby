require_relative '../lib/chatkit'

chatkit = Chatkit::Client.new({
  instance_locator: "v1:us1:some-instance-id",
  key: "the-id-bit:the-secret-bit"
})

users = [
  {
    id: 'user1',
    name: 'some Name1'
  },
  {
    id: 'user2',
    name: 'some Name2'
  },
  {
    id: 'user3',
    name: 'some Name3',
    avatar_url: 'https://placekitten.com/200/300',
    custom_data: { some: 'custom data' }
  }
]

p chatkit.create_users({ users: users })
