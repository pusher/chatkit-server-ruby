# coding: utf-8
require 'spec_helper'
require 'time'
require 'securerandom'

describe Chatkit::Client do
  before(:example) do
    @chatkit = Chatkit::Client.new({
      instance_locator: ENV['CHATKIT_INSTANCE_LOCATOR'],
      key: ENV['CHATKIT_INSTANCE_KEY']
    })

    @chatkit.api_request(
      method: 'DELETE',
      path: '/resources',
      jwt: @chatkit.generate_su_token[:token]
    )
  end

  describe '#authenticate' do
    it "should raise an ArgumentError if no options are provided" do
      expect { @chatkit.authenticate }.to raise_error ArgumentError
    end

    it "should return a token payload if a user_id is provided" do
      auth = @chatkit.authenticate({ user_id: 'ham' })
      expect(auth.status).to eq 200
      expect(auth.headers).to be_empty
      expect(auth.body[:token_type]).to eq 'bearer'
      expect(auth.body[:expires_in]).to eq 24 * 60 * 60
      expect(auth.body).to have_key :access_token
    end
  end

  describe '#generate_access_token' do
    describe "should raise an ArgumentError if" do
      it "no options are provided" do
        expect { @chatkit.generate_access_token }.to raise_error ArgumentError
      end

      it "empty options are provided" do
        expect {
          @chatkit.generate_access_token({})
        }.to raise_error Chatkit::Error
      end
    end

    describe "should return a token payload if" do
      it "a user_id is provided" do
        token_payload = @chatkit.generate_access_token({ user_id: 'ham' })
        expect(token_payload[:expires_in]).to eq 24 * 60 * 60
        expect(token_payload).to have_key :token
      end

      it "`su: true` is provided" do
        token_payload = @chatkit.generate_access_token({ su: true })
        expect(token_payload[:expires_in]).to eq 24 * 60 * 60
        expect(token_payload).to have_key :token
      end
    end
  end

  describe '#generate_su_token' do
    describe "should return a token payload if" do
      it "no options are provided" do
        token_payload = @chatkit.generate_su_token
        expect(token_payload[:expires_in]).to eq 24 * 60 * 60
        expect(token_payload).to have_key :token
      end

      it "a user_id is provided" do
        token_payload = @chatkit.generate_su_token({ user_id: 'ham' })
        expect(token_payload[:expires_in]).to eq 24 * 60 * 60
        expect(token_payload).to have_key :token
      end
    end
  end

  describe '#create_user' do
    describe "should raise a MissingParameterError if" do
      it "no id is provided" do
        expect {
          @chatkit.create_user({ name: 'Ham' })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no name is provided" do
        expect {
          @chatkit.create_user({ id: 'ham' })
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "an id and name are provided" do
        user_id = SecureRandom.uuid
        res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(res[:status]).to eq 201
        expect(res[:headers]).to_not be_empty
        expect(res[:body][:id]).to eq user_id
        expect(res[:body][:name]).to eq 'Ham'
      end

      it "an id, name, avatar_url and custom_data are provided" do
        user_id = SecureRandom.uuid
        res = @chatkit.create_user({
          id: user_id,
          name: 'Ham',
          avatar_url: 'https://placekitten.com/200/300',
          custom_data: { something: 'CUSTOM' }
        })
        expect(res[:status]).to eq 201
        expect(res[:body][:id]).to eq user_id
        expect(res[:body][:name]).to eq 'Ham'
        expect(res[:body][:avatar_url]).to eq 'https://placekitten.com/200/300'
        expect(res[:body][:custom_data]).to eq({ something: 'CUSTOM' })
      end
    end
  end

  describe '#create_users' do
    describe "should raise a MissingParameterError if" do
      it "no users are provided" do
        expect {
          @chatkit.create_user({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a valid set of options are provided" do
        user_id = SecureRandom.uuid
        user_id2 = SecureRandom.uuid
        res = @chatkit.create_users({
          users: [
            { id: user_id, name: 'Ham' },
            { id: user_id2, name: 'Ham2' }
          ]
        })
        expect(res[:status]).to eq 201
        expect(res[:headers]).to_not be_empty
        ids = res[:body].map { |u| u[:id] }
        names = res[:body].map { |u| u[:name] }
        expect(ids - [user_id, user_id2]).to be_empty
        expect(names - ['Ham', 'Ham2']).to be_empty
      end
    end
  end

  describe '#update_user' do
    describe "should raise a MissingParameterError if" do
      it "no id is provided" do
        expect {
          @chatkit.update_user({ name: 'Ham' })
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a valid set of options are provided" do
        user_id = SecureRandom.uuid
        create_res = @chatkit.create_user({
          id: user_id,
          name: 'Ham',
          avatar_url: 'https://placekitten.com/200/300',
          custom_data: { something: 'CUSTOM' }
        })
        expect(create_res[:status]).to eq 201

        update_res = @chatkit.update_user({
          id: user_id,
          name: 'No longer Ham',
          avatar_url: 'https://test.update.com',
          custom_data: { something: 'NEW', and: 777 }
        })
        expect(update_res[:status]).to eq 204
        expect(update_res[:body]).to be_nil
      end
    end
  end

  describe '#delete_user' do
    describe "should raise a MissingParameterError if" do
      it "no id is provided" do
        expect {
          @chatkit.async_delete_user({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      user_id = SecureRandom.uuid
      it "an id is provided" do
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        update_res = @chatkit.async_delete_user({ id: user_id })
        expect(update_res[:status]).to eq 202
        job_id = update_res[:body][:id]

        status_res = @chatkit.get_delete_status({ id: job_id })
        expect(status_res[:status]).to eq 200
        expect(status_res[:body][:status]).to_not be_empty
        expect(status_res[:body][:status]).to_not eq "failed"
      end
    end
  end

  describe '#get_user' do
    describe "should raise a MissingParameterError if" do
      it "no id is provided" do
        expect {
          @chatkit.get_user({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "an id is provided" do
        user_id = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        update_res = @chatkit.get_user({ id: user_id })
        expect(update_res[:status]).to eq 200
        expect(create_res[:body][:id]).to eq user_id
        expect(create_res[:body][:name]).to eq 'Ham'
      end

      it "the user id is weird" do
        user_id = "🍓🍓🍓"
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        update_res = @chatkit.get_user({ id: user_id })
        expect(update_res[:status]).to eq 200
        expect(create_res[:body][:id]).to eq user_id
        expect(create_res[:body][:name]).to eq 'Ham'
      end

    end
  end

  describe '#get_users' do
    describe "should return response payload if" do
      it "no options are provided" do
        user_id = SecureRandom.uuid
        user_id2 = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201
        create_res_two = @chatkit.create_user({ id: user_id2, name: 'Ham2' })
        expect(create_res_two[:status]).to eq 201

        get_users_res = @chatkit.get_users
        expect(get_users_res[:status]).to eq 200
        expect(get_users_res[:body][0][:id]).to eq user_id
        expect(get_users_res[:body][0][:name]).to eq 'Ham'
        expect(get_users_res[:body][1][:id]).to eq user_id2
        expect(get_users_res[:body][1][:name]).to eq 'Ham2'
      end

      it "a limit is provided" do
        user_id = SecureRandom.uuid
        user_id2 = SecureRandom.uuid
        res = @chatkit.create_users({
          users: [
            { id: user_id, name: 'Ham' },
            { id: user_id2, name: 'Ham2' }
          ]
        })
        expect(res[:status]).to eq 201

        get_users_res = @chatkit.get_users({ limit: 2 })
        expect(get_users_res[:status]).to eq 200
        expect(get_users_res[:body].count).to eq 2

        users_sorted = get_users_res[:body].sort { |a, b| a[:name] <=> b[:name] }

        expect(users_sorted[0][:name]).to eq 'Ham'
        expect(users_sorted[0][:id]).to eq user_id
        expect(users_sorted[1][:name]).to eq 'Ham2'
        expect(users_sorted[1][:id]).to eq user_id2
      end

      it "from_timestamp is provided" do
        user_id = SecureRandom.uuid
        user_id2 = SecureRandom.uuid

        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        sleep 2

        create_res_two = @chatkit.create_user({ id: user_id2, name: 'Ham2' })
        expect(create_res_two[:status]).to eq 201

        get_users_res = @chatkit.get_users({ from_timestamp: create_res[:body][:created_at] })

        expect(get_users_res[:status]).to eq 200
        expect(get_users_res[:body].count).to eq 2
        expect(get_users_res[:body][0][:id]).to eq user_id
        expect(get_users_res[:body][0][:name]).to eq 'Ham'
        expect(get_users_res[:body][1][:id]).to eq user_id2
        expect(get_users_res[:body][1][:name]).to eq 'Ham2'

        get_users_res_two = @chatkit.get_users({ from_timestamp: create_res_two[:body][:created_at] })
        expect(get_users_res_two[:status]).to eq 200
        expect(get_users_res_two[:body].count).to eq 1
        expect(get_users_res_two[:body][0][:id]).to eq user_id2
        expect(get_users_res_two[:body][0][:name]).to eq 'Ham2'
      end
    end
  end

  describe '#get_users_by_id' do
    describe "should raise a MissingParameterError if" do
      it "no user_ids are provided" do
        expect {
          @chatkit.get_users_by_id({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "user_ids are provided" do
        user_id = SecureRandom.uuid
        user_id2 = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201
        create_res_two = @chatkit.create_user({ id: user_id2, name: 'Ham2' })
        expect(create_res_two[:status]).to eq 201

        get_users_res = @chatkit.get_users_by_id({ user_ids: [user_id, user_id2] })
        expect(get_users_res[:status]).to eq 200
        expect(get_users_res[:body].count).to eq 2
        ids = get_users_res[:body].map { |u| u[:id] }
        names = get_users_res[:body].map { |u| u[:name] }
        expect(ids - [user_id, user_id2]).to be_empty
        expect(names - ['Ham', 'Ham2']).to be_empty
      end
    end
  end

  describe '#create_room' do
    describe "should raise a MissingParameterError if" do
      it "no name is provided" do
        expect {
          @chatkit.create_user({ creator_id: 'ham' })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no creator_id is provided" do
        expect {
          @chatkit.create_room({ name: 'my room' })
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a creator_id and name are provided" do
        user_id = SecureRandom.uuid
        res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(res[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201
        expect(room_res[:body]).to have_key :id
        expect(room_res[:body][:name]).to eq 'my room'
        expect(room_res[:body][:private]).to be false
        expect(room_res[:body][:member_user_ids]).to eq [user_id]
      end

      it "a creator_id, name, user_ids are provided and the room is private" do
        user_id = SecureRandom.uuid
        user_id2 = SecureRandom.uuid
        res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(res[:status]).to eq 201

        res_two = @chatkit.create_user({ id: user_id2, name: 'Ham2' })
        expect(res_two[:status]).to eq 201

        room_res = @chatkit.create_room({
          creator_id: user_id,
          name: 'my room',
          user_ids: [user_id2],
          private: true
        })
        expect(room_res[:status]).to eq 201
        expect(room_res[:body]).to have_key :id
        expect(room_res[:body][:name]).to eq 'my room'
        expect(room_res[:body][:private]).to be true
        expect(room_res[:body][:member_user_ids] - [user_id, user_id2]).to be_empty
      end

      it "a creator_id, name and custom_data are provided" do
        user_id = SecureRandom.uuid
        res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(res[:status]).to eq 201

        room_res = @chatkit.create_room({
          creator_id: user_id,
          name: 'my room',
          custom_data: { foo: 'bar' }
        })
        expect(room_res[:status]).to eq 201
        expect(room_res[:body]).to have_key :id
        expect(room_res[:body][:name]).to eq 'my room'
        expect(room_res[:body][:custom_data][:foo]).to eq 'bar'
      end

      it "a room id, creator_id and name are provided" do
        user_id = SecureRandom.uuid
        res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(res[:status]).to eq 201

        room_res = @chatkit.create_room({ id: "testroom", creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201
        expect(room_res[:body]).to have_key :id
        expect(room_res[:body][:id]).to eq 'testroom'
        expect(room_res[:body][:name]).to eq 'my room'
        expect(room_res[:body][:private]).to be false
        expect(room_res[:body][:member_user_ids]).to eq [user_id]
      end
    end
  end

  describe '#update_room' do
    describe "should raise a MissingParameterError if" do
      it "no id is provided" do
        expect {
          @chatkit.update_room({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a valid set of options are provided" do
        user_id = SecureRandom.uuid
        res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(res[:status]).to eq 201

        room_res = @chatkit.create_room({
          creator_id: user_id,
          name: 'my room',
          private: true,
          custom_data: { foo: 'bar', id: 1 }
        })
        expect(room_res[:status]).to eq 201

        update_res = @chatkit.update_room({
          id: room_res[:body][:id],
          name: 'New room name',
          private: false,
          custom_data: { foo: 'baz', id: 2 }
        })
        expect(update_res[:status]).to eq 204
        expect(update_res[:body]).to be_nil

        get_room_res = @chatkit.get_room({ id: room_res[:body][:id] })
        expect(get_room_res[:status]).to eq 200
        expect(get_room_res[:body][:id]).to eq room_res[:body][:id]
        expect(get_room_res[:body][:name]).to eq 'New room name'
        expect(get_room_res[:body][:private]).to eq false
        expect(get_room_res[:body][:custom_data][:foo]).to eq 'baz'
        expect(get_room_res[:body][:custom_data][:id]).to eq 2
      end
    end
  end

  describe '#delete_room' do
    describe "should raise a MissingParameterError if" do
      it "no id is provided" do
        expect {
          @chatkit.async_delete_room({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "an id is provided" do
        user_id = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201
        room_id = room_res[:id]

        update_res = @chatkit.async_delete_room({ id: room_res[:body][:id] })
        expect(update_res[:status]).to eq 202
        job_id = update_res[:body][:id]

        status_res = @chatkit.get_delete_status({ id: job_id })
        expect(status_res[:status]).to eq 200
        expect(status_res[:body][:status]).to_not be_empty
        expect(status_res[:body][:status]).to_not eq "failed"
      end
    end
  end

  describe '#get_room' do
    describe "should raise a MissingParameterError if" do
      it "no id is provided" do
        expect {
          @chatkit.get_room({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "an id is provided" do
        user_id = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        get_room_res = @chatkit.get_room({ id: room_res[:body][:id] })
        expect(get_room_res[:status]).to eq 200
        expect(get_room_res[:body][:id]).to eq room_res[:body][:id]
        expect(get_room_res[:body][:name]).to eq 'my room'
        expect(get_room_res[:body][:private]).to be false
        expect(get_room_res[:body][:member_user_ids]).to eq [user_id]
      end
    end
  end

  describe '#get_rooms' do
    describe "should return response payload if" do
      it "no options are provided" do
        user_id = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        get_rooms_res = @chatkit.get_rooms()
        expect(get_rooms_res[:status]).to eq 200
        expect(get_rooms_res[:body].count).to eq 1
        expect(get_rooms_res[:body][0][:id]).to eq room_res[:body][:id]
        expect(get_rooms_res[:body][0][:name]).to eq 'my room'
        expect(get_rooms_res[:body][0][:private]).to be false
      end

      it "include_private is specified" do
        user_id = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        room_res = @chatkit.create_room({
          creator_id: user_id,
          name: 'my room',
          private: true
        })
        expect(room_res[:status]).to eq 201

        get_rooms_res = @chatkit.get_rooms()
        expect(get_rooms_res[:status]).to eq 200
        expect(get_rooms_res[:body].count).to eq 0

        get_rooms_with_private_res = @chatkit.get_rooms({ include_private: true })
        expect(get_rooms_with_private_res[:status]).to eq 200
        expect(get_rooms_with_private_res[:body].count).to eq 1
        expect(get_rooms_with_private_res[:body][0][:id]).to eq room_res[:body][:id]
        expect(get_rooms_with_private_res[:body][0][:name]).to eq 'my room'
        expect(get_rooms_with_private_res[:body][0][:private]).to be true
      end

      it "include_private and from_id are specified" do
        user_id = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        room_res = @chatkit.create_room({
          creator_id: user_id,
          name: 'my room',
          private: true
        })
        expect(room_res[:status]).to eq 201

        room_res_two = @chatkit.create_room({ creator_id: user_id, name: 'my room 2' })
        expect(room_res_two[:status]).to eq 201

        if room_res[:body][:id] > room_res_two[:body][:id] then
          # swap the room responses to match the order we expect them to be returned in
          room_res_two, room_res = room_res, room_res_two
        end

        get_rooms_res_one = @chatkit.get_rooms({
          include_private: true,
          from_id: room_res[:body][:id]
        })
        expect(get_rooms_res_one[:status]).to eq 200
        expect(get_rooms_res_one[:body].count).to eq 1
        expect(get_rooms_res_one[:body][0][:id]).to eq room_res_two[:body][:id]
        expect(get_rooms_res_one[:body][0][:name]).to eq room_res_two[:body][:name]
        expect(get_rooms_res_one[:body][0][:private]).to eq room_res_two[:body][:private]

        get_rooms_res_two = @chatkit.get_rooms({
          include_private: true,
          from_id: room_res_two[:body][:id]
        })
        expect(get_rooms_res_two[:status]).to eq 200
        expect(get_rooms_res_two[:body].count).to eq 0
      end
    end
  end

  describe '#get_user_rooms' do
    describe "should raise a MissingParameterError if" do
      it "no id is provided" do
        expect {
          @chatkit.get_user_rooms({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "an id is provided" do
        user_id = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        get_user_rooms_res = @chatkit.get_user_rooms({ id: user_id })
        expect(get_user_rooms_res[:status]).to eq 200
        expect(get_user_rooms_res[:body].count).to eq 1
        expect(get_user_rooms_res[:body][0][:id]).to eq room_res[:body][:id]
        expect(get_user_rooms_res[:body][0][:name]).to eq 'my room'
        expect(get_user_rooms_res[:body][0][:private]).to be false
        expect(get_user_rooms_res[:body][0][:member_user_ids]).to eq [user_id]
      end

      it "an id is provided and only return the correct rooms" do
        user_id = SecureRandom.uuid
        user_id2 = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        create_res_two = @chatkit.create_user({ id: user_id2, name: 'Sarah' })
        expect(create_res_two[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        room_res_two = @chatkit.create_room({ creator_id: user_id2, name: 'sarah room' })
        expect(room_res_two[:status]).to eq 201

        get_user_rooms_res = @chatkit.get_user_rooms({ id: user_id })
        expect(get_user_rooms_res[:status]).to eq 200
        expect(get_user_rooms_res[:body].count).to eq 1
        expect(get_user_rooms_res[:body][0][:id]).to eq room_res[:body][:id]
        expect(get_user_rooms_res[:body][0][:name]).to eq 'my room'
        expect(get_user_rooms_res[:body][0][:private]).to be false
        expect(get_user_rooms_res[:body][0][:member_user_ids]).to eq [user_id]
      end
    end

    describe "should contain unread counts" do
      it "with and without messages in room" do
        user_id = make_user()
        room_id = make_room(user_id)

        # cursor unset
        # messages 0
        # unread count 0
        res = @chatkit.get_user_rooms({ id: user_id })
        expect(res[:body][0][:unread_count]).to eq 0

        # cursor unset
        # messages 1
        # unread count 1
        messages = make_messages(user_id, room_id, ['hi'])
        res = @chatkit.get_user_rooms({ id: user_id })
        expect(res[:body][0][:unread_count]).to eq 1

        # cursor set to message 1
        # messages 1
        # unread count 0
        @chatkit.set_read_cursor({
          room_id: room_id,
          user_id: user_id,
          position: messages.keys()[0]
        })
        res = @chatkit.get_user_rooms({ id: user_id })
        expect(res[:body][0][:unread_count]).to eq 0

        # cursor set to message 1
        # messages 3
        # unread count 1
        make_messages(user_id, room_id, ['hi!', 'hello!'])
        res = @chatkit.get_user_rooms({ id: user_id })
        expect(res[:body][0][:unread_count]).to eq 2
      end
    end
  end

  describe '#get_user_joinable_rooms' do
    describe "should raise a MissingParameterError if" do
      it "no id is provided" do
        expect {
          @chatkit.get_user_joinable_rooms({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "an id is provided" do
        user_id = SecureRandom.uuid
        user_id2 = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        get_user_rooms_res = @chatkit.get_user_joinable_rooms({ id: user_id })
        expect(get_user_rooms_res[:status]).to eq 200
        expect(get_user_rooms_res[:body].count).to eq 0

        create_res_two = @chatkit.create_user({ id: user_id2, name: 'Sarah' })
        expect(create_res_two[:status]).to eq 201

        room_res_two = @chatkit.create_room({ creator_id: user_id2, name: 'sarah room' })
        expect(room_res_two[:status]).to eq 201

        get_user_rooms_res = @chatkit.get_user_joinable_rooms({ id: user_id })
        expect(get_user_rooms_res[:status]).to eq 200
        expect(get_user_rooms_res[:body].count).to eq 1
        expect(get_user_rooms_res[:body][0][:id]).to eq room_res_two[:body][:id]
        expect(get_user_rooms_res[:body][0][:name]).to eq 'sarah room'
        expect(get_user_rooms_res[:body][0][:private]).to be false
        expect(get_user_rooms_res[:body][0][:member_user_ids]).to eq [user_id2]
      end
    end
  end

  describe '#add_users_to_room' do
    describe "should raise a MissingParameterError if" do
      it "no room_id is provided" do
        expect {
          @chatkit.add_users_to_room({ user_ids: ['sarah'] })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no user_ids are provided" do
        expect {
          @chatkit.add_users_to_room({ room_id: "123" })
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "an id is provided" do
        user_id = SecureRandom.uuid
        user_id2 = SecureRandom.uuid
        user_id3 = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        create_res_two = @chatkit.create_user({ id: user_id2, name: 'Ham 2' })
        expect(create_res_two[:status]).to eq 201

        create_res_three = @chatkit.create_user({ id: user_id3, name: 'Ham 3' })
        expect(create_res_three[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        add_users_res = @chatkit.add_users_to_room({
          room_id: room_res[:body][:id],
          user_ids: [user_id2, user_id3]
        })
        expect(add_users_res[:status]).to eq 204
        expect(add_users_res[:body]).to be_nil

        get_room_res = @chatkit.get_room({ id: room_res[:body][:id] })
        expect(get_room_res[:status]).to eq 200
        expect(get_room_res[:body][:id]).to eq room_res[:body][:id]
        expect(get_room_res[:body][:name]).to eq 'my room'
        expect(get_room_res[:body][:private]).to be false
        expect(get_room_res[:body][:member_user_ids] - [user_id, user_id2, user_id3]).to be_empty
      end
    end
  end

  describe '#remove_users_from_room' do
    describe "should raise a MissingParameterError if" do
      it "no room_id is provided" do
        expect {
          @chatkit.remove_users_from_room({ user_ids: ['sarah'] })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no user_ids are provided" do
        expect {
          @chatkit.remove_users_from_room({ room_id: "123" })
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "an id is provided" do
        user_id = SecureRandom.uuid
        user_id2 = SecureRandom.uuid
        user_id3 = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        create_res_two = @chatkit.create_user({ id: user_id2, name: 'Ham 2' })
        expect(create_res_two[:status]).to eq 201

        create_res_three = @chatkit.create_user({ id: user_id3, name: 'Ham 3' })
        expect(create_res_three[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        room_res = @chatkit.create_room({
          creator_id: user_id,
          name: 'my room',
          user_ids: [user_id2, user_id3]
        })
        expect(room_res[:status]).to eq 201

        remove_users_res = @chatkit.remove_users_from_room({
          room_id: room_res[:body][:id],
          user_ids: [user_id2, user_id3]
        })
        expect(remove_users_res[:status]).to eq 204
        expect(remove_users_res[:body]).to be_nil

        get_room_res = @chatkit.get_room({ id: room_res[:body][:id] })
        expect(get_room_res[:status]).to eq 200
        expect(get_room_res[:body][:id]).to eq room_res[:body][:id]
        expect(get_room_res[:body][:name]).to eq 'my room'
        expect(get_room_res[:body][:private]).to be false
        expect(get_room_res[:body][:member_user_ids]).to eq [user_id]
      end
    end
  end

  describe '#send_message' do
    describe "should raise a MissingParameterError if" do
      it "no room_id is provided" do
        expect {
          @chatkit.send_message({ text: 'hi', sender_id: 'ham' })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no sender_id is provided" do
        expect {
          @chatkit.send_message({ text: 'hi', room_id: "123" })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no text is provided" do
        expect {
          @chatkit.send_message({ sender_id: 'ham', room_id: "123" })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no resource_link is provided for a message with an attachment" do
        expect {
          @chatkit.send_message({
            sender_id: 'ham',
            room_id: "123",
            text: 'test',
            attachment: {
              type: 'image'
            }
          })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no type is provided for a message with an attachment" do
        expect {
          @chatkit.send_message({
            sender_id: 'ham',
            room_id: "123",
            text: 'test',
            attachment: {
              resource_link: 'https://placekitten.com/200/300'
            }
          })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "an invalid type is provided for a message with an attachment" do
        expect {
          @chatkit.send_message({
            sender_id: 'ham',
            room_id: "123",
            text: 'test',
            attachment: {
              resource_link: 'https://placekitten.com/200/300',
              type: 'wrong'
            }
          })
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a room_id, sender_id, and text are provided" do
        user_id = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        send_message_res = @chatkit.send_message({
          room_id: room_res[:body][:id],
          sender_id: user_id,
          text: 'hi 1'
        })
        expect(send_message_res[:status]).to eq 201
        expect(send_message_res[:body]).to have_key :message_id
      end

      it "a room_id, sender_id, text, and a link attachment are provided" do
        user_id = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        send_message_res = @chatkit.send_message({
          room_id: room_res[:body][:id],
          sender_id: user_id,
          text: 'hi 1',
          attachment: {
            resource_link: 'https://placekitten.com/200/300',
            type: 'image'
          }
        })
        expect(send_message_res[:status]).to eq 201
        expect(send_message_res[:body]).to have_key :message_id
      end
    end
  end

  describe '#send_simple_message' do
    describe "should raise a MissingParameterError if" do
      it "no room_id is provided" do
        expect {
          @chatkit.send_simple_message({ text: 'hi', sender_id: 'ham' })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no sender_id is provided" do
        expect {
          @chatkit.send_simple_message({ text: 'hi', room_id: "123" })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no text is provided" do
        expect {
          @chatkit.send_simple_message({ sender_id: 'ham', room_id: "123" })
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a room_id, sender_id, and text are provided" do
        user_id = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        send_message_res = @chatkit.send_simple_message({
          room_id: room_res[:body][:id],
          sender_id: user_id,
          text: 'hi 1'
        })
        expect(send_message_res[:status]).to eq 201
        expect(send_message_res[:body]).to have_key :message_id
      end
    end
  end

  describe '#send_multipart_message' do
    good_parts = [{type: "text/plain", content: "hi"},
                  {type: "image/png", url: "https://placekitten.com/200/300"},
                  {type: "binary/octet-stream",
                   file: Random.new.bytes(100),
                   name: "random bytes",
                   customData: {some: "json", data: 42}
                  }
                 ]

    describe "should raise a MissingParameterError if" do
      it "no room_id is provided" do
        expect {
          @chatkit.send_multipart_message({ sender_id: 'ham', parts:  good_parts})
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no sender_id is provided" do
        expect {
          @chatkit.send_multipart_message({ room_id: "123", parts: good_parts })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no parts are provided" do
        expect {
          @chatkit.send_multipart_message({ sender_id: 'ham', room_id: "123" })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no type is provided for a part" do
        expect {
          @chatkit.send_multipart_message(
            {sender_id: 'ham',
             room_id: "123",
             parts: [{ content: 'test' }]
            })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "only type is provided for a part" do
        expect {
          @chatkit.send_multipart_message(
            {sender_id: 'ham',
             room_id: "123",
             parts: [{ type: 'text/plain' }]
            })
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a room_id, sender_id, and parts are provided" do
        user_id = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        send_message_res = @chatkit.send_multipart_message({
          room_id: room_res[:body][:id],
          sender_id: user_id,
          parts: good_parts
        })
        expect(send_message_res[:status]).to eq 201
        expect(send_message_res[:body]).to have_key :message_id
      end
    end
  end

  describe '#get_room_messages' do
    describe "should raise a MissingParameterError if" do
      it "no room_id is provided" do
        expect {
          @chatkit.get_room_messages({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a room_id is provided" do
        user_id = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        send_message_res = @chatkit.send_message({
          room_id: room_res[:body][:id],
          sender_id: user_id,
          text: 'hi 1'
        })
        expect(send_message_res[:status]).to eq 201

        send_message_res_two = @chatkit.send_message({
          room_id: room_res[:body][:id],
          sender_id: user_id,
          text: 'hi 2'
        })
        expect(send_message_res_two[:status]).to eq 201

        get_messages_res = @chatkit.get_room_messages({ room_id: room_res[:body][:id] })
        expect(get_messages_res[:status]).to eq 200
        expect(get_messages_res[:body].count).to eq 2
        expect(get_messages_res[:body][0][:id]).to eq send_message_res_two[:body][:message_id]
        expect(get_messages_res[:body][0][:text]).to eq 'hi 2'
        expect(get_messages_res[:body][0][:user_id]).to eq user_id
        expect(get_messages_res[:body][0][:room_id]).to eq room_res[:body][:id]
        expect(get_messages_res[:body][1][:id]).to eq send_message_res[:body][:message_id]
        expect(get_messages_res[:body][1][:text]).to eq 'hi 1'
        expect(get_messages_res[:body][1][:user_id]).to eq user_id
        expect(get_messages_res[:body][1][:room_id]).to eq room_res[:body][:id]
      end

      it "a room_id, initial_id, direction, and limit are provided" do
        user_id = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        send_options = { room_id: room_res[:body][:id], sender_id: user_id }

        send_message_res = @chatkit.send_message(send_options.merge(text: 'hi 1'))
        expect(send_message_res[:status]).to eq 201
        send_message_res_two = @chatkit.send_message(send_options.merge(text: 'hi 2'))
        expect(send_message_res_two[:status]).to eq 201
        send_message_res_three = @chatkit.send_message(send_options.merge(text: 'hi 3'))
        expect(send_message_res_three[:status]).to eq 201
        send_message_res_four = @chatkit.send_message(send_options.merge(text: 'hi 4'))
        expect(send_message_res_four[:status]).to eq 201

        get_messages_res_custom = @chatkit.get_room_messages({
          room_id: room_res[:body][:id],
          limit: 2,
          direction: 'newer',
          initial_id: send_message_res_two[:body][:message_id]
        })

        expect(get_messages_res_custom[:status]).to eq 200
        expect(get_messages_res_custom[:body].count).to eq 2
        expect(get_messages_res_custom[:body][0][:id]).to eq send_message_res_three[:body][:message_id]
        expect(get_messages_res_custom[:body][0][:text]).to eq 'hi 3'
        expect(get_messages_res_custom[:body][0][:user_id]).to eq user_id
        expect(get_messages_res_custom[:body][0][:room_id]).to eq room_res[:body][:id]
        expect(get_messages_res_custom[:body][1][:id]).to eq send_message_res_four[:body][:message_id]
        expect(get_messages_res_custom[:body][1][:text]).to eq 'hi 4'
        expect(get_messages_res_custom[:body][1][:user_id]).to eq user_id
        expect(get_messages_res_custom[:body][1][:room_id]).to eq room_res[:body][:id]
      end
    end
  end

  describe '#fetch_multipart_messages' do
    describe "should raise a MissingParameterError if" do
      it "no room_id is provided" do
        expect {
          @chatkit.fetch_multipart_messages({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a room_id is provided" do
        user_id = make_user()
        room_id = make_room(user_id)

        messages = make_messages(user_id, room_id,
                                 ['hi 1', 'hi 2'])

        get_messages_res = @chatkit.fetch_multipart_messages({ room_id: room_id })
        expect(get_messages_res[:status]).to eq 200

        get_messages_res[:body].each { |message|
          expect(message[:room_id]).to eq room_id
          expect(message[:user_id]).to eq user_id

          message_id = message[:id]
          content = message[:parts][0][:content]
          expect(content).to eq messages[message_id]
        }
      end

      it "a room_id, initial_id, direction, and limit are provided" do
        user_id = make_user()
        room_id = make_room(user_id)

        messages = make_messages(user_id, room_id,
                                 ['hi 1', 'hi 2', 'hi 3', 'hi 4'])

        # the query should return only these messages
        expected_messages = Hash[messages.to_a[2..3]]

        get_messages_res_custom = @chatkit.fetch_multipart_messages({
          room_id: room_id,
          limit: 2,
          direction: 'newer',
          initial_id: messages.keys[1]
        })

        expect(get_messages_res_custom[:status]).to eq 200

        get_messages_res_custom[:body].each { |message|
          expect(message[:room_id]).to eq room_id
          expect(message[:user_id]).to eq user_id

          message_id = message[:id]
          content = message[:parts][0][:content]
          expect(content).to eq expected_messages[message_id]
        }
      end

      it "an attachment is provided" do
        user_id = make_user()
        room_id = make_room(user_id)

        payload = Random.new.bytes(100)

        part =
          {type: "binary/octet-stream",
           file: payload,
           name: "random bytes",
           customData: {some: "json", data: 42}
          }

        @chatkit.send_multipart_message(
          {sender_id: user_id,
           room_id: room_id,
           parts: [part]
          })

        get_messages_res = @chatkit.fetch_multipart_messages({
          room_id: room_id
        })

        expect(get_messages_res[:status]).to eq 200

        get_messages_res[:body].each { |message|
          expect(message[:room_id]).to eq room_id
          expect(message[:user_id]).to eq user_id

          message_id = message[:id]
          attachment_url = message[:parts][0][:attachment][:download_url]
          response = Excon.new(attachment_url, :omit_default_port => true).get
          expect(response[:status]).to eq 200
          expect(response[:body]).to eq payload
        }
      end
    end
  end

  describe '#delete_message' do
    describe "should raise a MissingParameterError if" do
      it "no id is provided" do
        expect {
          @chatkit.delete_message({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "an id is provided" do
        user_id = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        send_message_res = @chatkit.send_message({
          room_id: room_res[:body][:id],
          sender_id: user_id,
          text: 'hi 1'
        })
        expect(send_message_res[:status]).to eq 201

        delete_messages_res = @chatkit.delete_message({
          message_id: send_message_res[:body][:message_id],
          room_id: room_res[:body][:id]
        })
        expect(delete_messages_res[:status]).to eq 204
        expect(delete_messages_res[:body]).to be_nil
      end
    end
  end

  describe '#create_global_role' do
    describe "should raise a MissingParameterError if" do
      it "no name is provided" do
        expect {
          @chatkit.create_global_role({ permissions: ['room:create'] })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no permissions key is provided" do
        expect {
          @chatkit.create_global_role({ name: 'test' })
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a name and permissions are provided" do
        role_name = SecureRandom.uuid
        create_res = @chatkit.create_global_role({
          name: role_name,
          permissions: ['room:create']
        })
        expect(create_res[:status]).to eq 201
        expect(create_res[:body]).to be_nil
      end
    end
  end

  describe '#create_room_role' do
    describe "should raise a MissingParameterError if" do
      it "no name is provided" do
        expect {
          @chatkit.create_room_role({ permissions: ['room:update'] })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no permissions key is provided" do
        expect {
          @chatkit.create_room_role({ name: 'test' })
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a name and permissions are provided" do
        role_name = SecureRandom.uuid
        create_res = @chatkit.create_room_role({
          name: role_name,
          permissions: ['room:update']
        })
        expect(create_res[:status]).to eq 201
        expect(create_res[:body]).to be_nil
      end
    end
  end

  describe '#delete_global_role' do
    describe "should raise a MissingParameterError if" do
      it "no name is provided" do
        expect {
          @chatkit.delete_global_role({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a name is provided" do
        role_name = SecureRandom.uuid
        create_res = @chatkit.create_global_role({
          name: role_name,
          permissions: ['room:create']
        })
        expect(create_res[:status]).to eq 201

        delete_res = @chatkit.delete_global_role({
          name: role_name
        })
        expect(delete_res[:status]).to eq 204
        expect(delete_res[:body]).to be_nil
      end
    end
  end

  describe '#delete_room_role' do
    describe "should raise a MissingParameterError if" do
      it "no name is provided" do
        expect {
          @chatkit.delete_room_role({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a name is provided" do
        role_name = SecureRandom.uuid
        create_res = @chatkit.create_room_role({
          name: role_name,
          permissions: ['room:update']
        })
        expect(create_res[:status]).to eq 201

        delete_res = @chatkit.delete_room_role({
          name: role_name
        })
        expect(delete_res[:status]).to eq 204
        expect(delete_res[:body]).to be_nil
      end
    end
  end

  describe '#assign_global_role_to_user' do
    describe "should raise a MissingParameterError if" do
      it "no user_id is provided" do
        expect {
          @chatkit.assign_global_role_to_user({ name: 'admin' })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no name is provided" do
        expect {
          @chatkit.assign_global_role_to_user({ user_id: 'ham' })
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a user_id and name are provided" do
        user_id = SecureRandom.uuid
        role_name = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        create_role_res = @chatkit.create_global_role({
          name: role_name,
          permissions: ['room:create']
        })
        expect(create_role_res[:status]).to eq 201

        assign_role_res = @chatkit.assign_global_role_to_user({
          user_id: user_id,
          name: role_name
        })
        expect(assign_role_res[:status]).to eq 201
        expect(assign_role_res[:body]).to be_nil
      end
    end
  end

  describe '#assign_room_role_to_user' do
    describe "should raise a MissingParameterError if" do
      it "no user_id is provided" do
        expect {
          @chatkit.assign_room_role_to_user({
            name: 'admin',
            room_id: "123"
          })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no name is provided" do
        expect {
          @chatkit.assign_room_role_to_user({
            user_id: 'ham',
            room_id: "123"
          })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no room_id is provided" do
        expect {
          @chatkit.assign_room_role_to_user({
            user_id: 'ham',
            name: 'admin'
          })
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      user_id = SecureRandom.uuid
      role_name = SecureRandom.uuid
      it "a user_id, name, and room_id are provided" do
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        create_role_res = @chatkit.create_room_role({
          name: role_name,
          permissions: ['room:update']
        })
        expect(create_role_res[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        assign_role_res = @chatkit.assign_room_role_to_user({
          user_id: user_id,
          name: role_name,
          room_id: room_res[:body][:id]
        })
        expect(assign_role_res[:status]).to eq 201
        expect(assign_role_res[:body]).to be_nil
      end
    end
  end

  describe '#get_roles' do
    describe "should return response payload if" do
      it "no parameters are provided" do
        role_name = SecureRandom.uuid
        create_role_res = @chatkit.create_room_role({
          name: role_name,
          permissions: ['room:update']
        })
        expect(create_role_res[:status]).to eq 201

        get_roles_res = @chatkit.get_roles
        expect(get_roles_res[:status]).to eq 200
        expect(get_roles_res[:body].count).to eq 1
        expect(get_roles_res[:body][0][:scope]).to eq 'room'
        expect(get_roles_res[:body][0][:name]).to eq role_name
        expect(get_roles_res[:body][0][:permissions]).to eq ['room:update']
      end
    end
  end

  describe '#get_user_roles' do
    describe "should raise a MissingParameterError if" do
      it "no user_id is provided" do
        expect {
          @chatkit.get_user_roles({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a user_id is provided" do
        user_id = SecureRandom.uuid
        role_name = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        create_role_res = @chatkit.create_global_role({
          name: role_name,
          permissions: ['room:update']
        })
        expect(create_role_res[:status]).to eq 201

        assign_role_res = @chatkit.assign_global_role_to_user({
          user_id: user_id,
          name: role_name
        })
        expect(assign_role_res[:status]).to eq 201

        get_user_roles_res = @chatkit.get_user_roles({ user_id: user_id })
        expect(get_user_roles_res[:status]).to eq 200
        expect(get_user_roles_res[:body].count).to eq 1
        expect(get_user_roles_res[:body][0][:scope]).to eq 'global'
        expect(get_user_roles_res[:body][0][:role_name]).to eq role_name
        expect(get_user_roles_res[:body][0][:permissions]).to eq ['room:update']
      end
    end
  end

  describe '#remove_global_role_for_user' do
    describe "should raise a MissingParameterError if" do
      it "no user_id is provided" do
        expect {
          @chatkit.remove_global_role_for_user({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a user_id is provided" do
        user_id = SecureRandom.uuid
        role_name = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        create_role_res = @chatkit.create_global_role({
          name: role_name,
          permissions: ['room:create']
        })
        expect(create_role_res[:status]).to eq 201

        assign_role_res = @chatkit.assign_global_role_to_user({
          user_id: user_id,
          name: role_name
        })
        expect(assign_role_res[:status]).to eq 201
        expect(assign_role_res[:body]).to be_nil

        remove_role_res = @chatkit.remove_global_role_for_user({
          user_id: user_id
        })
        expect(remove_role_res[:status]).to eq 204
        expect(remove_role_res[:body]).to be_nil
      end
    end
  end

  describe '#remove_room_role_for_user' do
    describe "should raise a MissingParameterError if" do
      it "no user_id is provided" do
        expect {
          @chatkit.remove_room_role_for_user({ room_id: "123" })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no room_id is provided" do
        expect {
          @chatkit.remove_room_role_for_user({ user_id: 'ham' })
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a user_id and room_id are provided" do
        user_id = SecureRandom.uuid
        role_name = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        create_role_res = @chatkit.create_room_role({
          name: role_name,
          permissions: ['room:update']
        })
        expect(create_role_res[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        assign_role_res = @chatkit.assign_room_role_to_user({
          user_id: user_id,
          name: role_name,
          room_id: room_res[:body][:id]
        })
        expect(assign_role_res[:status]).to eq 201

        remove_role_res = @chatkit.remove_room_role_for_user({
          user_id: user_id,
          room_id: room_res[:body][:id]
        })
        expect(remove_role_res[:status]).to eq 204
        expect(remove_role_res[:body]).to be_nil
      end
    end
  end

  describe '#get_permissions_for_global_role' do
    describe "should raise a MissingParameterError if" do
      it "no name is provided" do
        expect {
          @chatkit.get_permissions_for_global_role({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a name is provided" do
        role_name = SecureRandom.uuid
        create_role_res = @chatkit.create_global_role({
          name: role_name,
          permissions: ['room:create']
        })
        expect(create_role_res[:status]).to eq 201

        get_role_perms_res = @chatkit.get_permissions_for_global_role({
          name: role_name
        })
        expect(get_role_perms_res[:status]).to eq 200
        expect(get_role_perms_res[:body]).to eq ['room:create']
      end
    end
  end

  describe '#get_permissions_for_room_role' do
    describe "should raise a MissingParameterError if" do
      it "no name is provided" do
        expect {
          @chatkit.get_permissions_for_room_role({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a name is provided" do
        role_name = SecureRandom.uuid
        create_role_res = @chatkit.create_room_role({
          name: role_name,
          permissions: ['room:update']
        })
        expect(create_role_res[:status]).to eq 201

        get_role_perms_res = @chatkit.get_permissions_for_room_role({
          name: role_name
        })
        expect(get_role_perms_res[:status]).to eq 200
        expect(get_role_perms_res[:body]).to eq ['room:update']
      end
    end
  end

  describe '#update_permissions_for_global_role' do
    describe "should raise a MissingParameterError if" do
      it "no name is provided" do
        expect {
          @chatkit.update_permissions_for_global_role({})
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no permissions to add or remove are provided" do
        expect {
          @chatkit.update_permissions_for_global_role({ name: 'admin' })
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a name is provided" do
        role_name = SecureRandom.uuid
        create_role_res = @chatkit.create_global_role({
          name: role_name,
          permissions: ['room:create']
        })
        expect(create_role_res[:status]).to eq 201

        update_perms_res = @chatkit.update_permissions_for_global_role({
          name: role_name,
          permissions_to_add: ['room:delete'],
          permissions_to_remove: ['room:create']
        })
        expect(update_perms_res[:status]).to eq 204
        expect(update_perms_res[:body]).to be_nil

        get_role_perms_res = @chatkit.get_permissions_for_global_role({
          name: role_name
        })
        expect(get_role_perms_res[:status]).to eq 200
        expect(get_role_perms_res[:body]).to eq ['room:delete']
      end
    end
  end

  describe '#update_permissions_for_room_role' do
    describe "should raise a MissingParameterError if" do
      it "no name is provided" do
        expect {
          @chatkit.update_permissions_for_room_role({})
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no permissions to add or remove are provided" do
        expect {
          @chatkit.update_permissions_for_room_role({ name: 'admin' })
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a name is provided" do
        role_name = SecureRandom.uuid
        create_role_res = @chatkit.create_room_role({
          name: role_name,
          permissions: ['room:update']
        })
        expect(create_role_res[:status]).to eq 201

        update_perms_res = @chatkit.update_permissions_for_room_role({
          name: role_name,
          permissions_to_add: ['room:delete'],
          permissions_to_remove: ['room:update']
        })
        expect(update_perms_res[:status]).to eq 204
        expect(update_perms_res[:body]).to be_nil

        get_role_perms_res = @chatkit.get_permissions_for_room_role({
          name: role_name
        })
        expect(get_role_perms_res[:status]).to eq 200
        expect(get_role_perms_res[:body]).to eq ['room:delete']
      end
    end
  end

  describe '#set_read_cursor' do
    describe "should raise a MissingParameterError if" do
      it "no room_id is provided" do
        expect {
          @chatkit.set_read_cursor({ user_id: 'ham', position: 123 })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no user_id is provided" do
        expect {
          @chatkit.set_read_cursor({ room_id: "123", position: 123 })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no position is provided" do
        expect {
          @chatkit.set_read_cursor({ room_id: "123", user_id: 'ham' })
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a room_id, position, and user_id are provided" do
        user_id = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        set_cursor_res = @chatkit.set_read_cursor({
          room_id: room_res[:body][:id],
          user_id: user_id,
          position: 123
        })
        expect(set_cursor_res[:status]).to eq 201
        expect(set_cursor_res[:body]).to eq({})
      end
    end
  end

  describe '#get_read_cursor' do
    describe "should raise a MissingParameterError if" do
      it "no room_id is provided" do
        expect {
          @chatkit.get_read_cursor({ user_id: 'ham' })
        }.to raise_error Chatkit::MissingParameterError
      end

      it "no user_id is provided" do
        expect {
          @chatkit.get_read_cursor({ room_id: "123" })
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a room_id and user_id are provided" do
        user_id = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        set_cursor_res = @chatkit.set_read_cursor({
          room_id: room_res[:body][:id],
          user_id: user_id,
          position: 123
        })
        expect(set_cursor_res[:status]).to eq 201

        get_cursor_res = @chatkit.get_read_cursor({
          room_id: room_res[:body][:id],
          user_id: user_id
        })
        expect(get_cursor_res[:status]).to eq 200
        expect(get_cursor_res[:body]).to have_key :updated_at
        expect(get_cursor_res[:body][:cursor_type]).to eq 0
        expect(get_cursor_res[:body][:position]).to eq 123
        expect(get_cursor_res[:body][:room_id]).to eq room_res[:body][:id]
        expect(get_cursor_res[:body][:user_id]).to eq user_id
      end
    end
  end

  describe '#get_user_read_cursors' do
    describe "should raise a MissingParameterError if" do
      it "no user_id is provided" do
        expect {
          @chatkit.get_user_read_cursors({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a user_id is provided" do
        user_id = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        set_cursor_res = @chatkit.set_read_cursor({
          room_id: room_res[:body][:id],
          user_id: user_id,
          position: 123
        })
        expect(set_cursor_res[:status]).to eq 201

        get_cursors_res = @chatkit.get_user_read_cursors({
          user_id: user_id
        })
        expect(get_cursors_res[:status]).to eq 200
        expect(get_cursors_res[:body].count).to eq 1
        expect(get_cursors_res[:body][0]).to have_key :updated_at
        expect(get_cursors_res[:body][0][:cursor_type]).to eq 0
        expect(get_cursors_res[:body][0][:position]).to eq 123
        expect(get_cursors_res[:body][0][:room_id]).to eq room_res[:body][:id]
        expect(get_cursors_res[:body][0][:user_id]).to eq user_id
      end
    end
  end

  describe '#get_room_read_cursors' do
    describe "should raise a MissingParameterError if" do
      it "no room_id is provided" do
        expect {
          @chatkit.get_room_read_cursors({})
        }.to raise_error Chatkit::MissingParameterError
      end
    end

    describe "should return response payload if" do
      it "a room_id is provided" do
        user_id = SecureRandom.uuid
        create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
        expect(create_res[:status]).to eq 201

        room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
        expect(room_res[:status]).to eq 201

        set_cursor_res = @chatkit.set_read_cursor({
          room_id: room_res[:body][:id],
          user_id: user_id,
          position: 123
        })
        expect(set_cursor_res[:status]).to eq 201

        get_cursors_res = @chatkit.get_room_read_cursors({
          room_id: room_res[:body][:id]
        })
        expect(get_cursors_res[:status]).to eq 200
        expect(get_cursors_res[:body].count).to eq 1
        expect(get_cursors_res[:body][0]).to have_key :updated_at
        expect(get_cursors_res[:body][0][:cursor_type]).to eq 0
        expect(get_cursors_res[:body][0][:position]).to eq 123
        expect(get_cursors_res[:body][0][:room_id]).to eq room_res[:body][:id]
        expect(get_cursors_res[:body][0][:user_id]).to eq user_id
      end
    end
  end
end

def make_user()
  user_id = SecureRandom.uuid
  create_res = @chatkit.create_user({ id: user_id, name: 'Ham' })
  expect(create_res[:status]).to eq 201
  user_id
end

def make_room(user_id)
  room_res = @chatkit.create_room({ creator_id: user_id, name: 'my room' })
  expect(room_res[:status]).to eq 201
  room_res[:body][:id]
end

def make_messages(sender_id, room_id, messages)
  result = {}
  messages.each { |message|
    send_message_res = @chatkit.send_simple_message(
      {room_id: room_id,
       sender_id: sender_id,
       text: message
      })
    expect(send_message_res[:status]).to eq 201
    message_id = send_message_res[:body][:message_id]
    result[message_id] = message
  }
  result
end
