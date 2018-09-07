require 'pusher-platform'
require 'json'

module Chatkit
  ROOM_SCOPE = "room"
  GLOBAL_SCOPE = "global"

  class Error < RuntimeError
  end

  class Client
    attr_accessor :api_instance, :authorizer_instance, :cursors_instance

    def initialize(options)
      base_options = {
        locator: options[:instance_locator],
        key: options[:key],
        port: options[:port],
        host: options[:host],
        client: options[:client]
      }

      @api_instance = PusherPlatform::Instance.new(
        base_options.merge!({
          service_name: 'chatkit',
          service_version: 'v1'
        })
      )

      @authorizer_instance = PusherPlatform::Instance.new(
        base_options.merge!({
          service_name: 'chatkit_authorizer',
          service_version: 'v1'
        })
      )

      @cursors_instance = PusherPlatform::Instance.new(
        base_options.merge!({
          service_name: 'chatkit_cursors',
          service_version: 'v1'
        })
      )
    end

    def authenticate(options)
      user_id = options['user_id'] || options[:user_id]
      auth_payload = options['auth_payload'] || options[:auth_payload] || {
        grant_type: 'client_credentials'
      }
      @api_instance.authenticate(auth_payload, { user_id: user_id })
    end

    def authenticate_with_request(request, options)
      @api_instance.authenticate_with_request(request, options)
    end

    def generate_access_token(options)
      @api_instance.generate_access_token(options)
    end

    def generate_su_token(options = {})
      generate_access_token({ su: true }.merge(options))[:token]
    end

    # User API

    def create_user(options)
      body = {
        id: options[:id],
        name: options[:name]
      }

      unless options[:avatar_url].nil?
        body[:avatar_url] = options[:avatar_url]
      end

      unless options[:custom_data].nil?
        body[:custom_data] = options[:custom_data]
      end

      res = @api_instance.request(
        method: "POST",
        path: "/users",
        headers: {
          "Content-Type": "application/json",
        },
        body: body,
        jwt: generate_su_token
      )

      JSON.parse(res.body)
    end

    def create_users(options)
      res = @api_instance.request(
        method: "POST",
        path: "/batch_users",
        headers: {
          "Content-Type": "application/json",
        },
        body: options,
        jwt: generate_su_token
      )

      JSON.parse(res.body)
    end

    def update_user(options)
      if options[:id].nil?
        raise Chatkit::Error.new("You must provide the ID of the user you want to update")
      end

      payload = {}
      payload[:name] = options[:name] unless options[:name].nil?
      payload[:avatar_url] = options[:avatar_url] unless options[:avatar_url].nil?
      payload[:custom_data] = options[:custom_data] unless options[:custom_data].nil?

      @api_instance.request(
        method: "PUT",
        path: "/users/#{options[:id]}",
        headers: {
          "Content-Type": "application/json",
        },
        body: payload,
        jwt: generate_su_token({ user_id: options[:id] })
      )
    end

    def delete_user(options)
      if options[:id].nil?
        raise Chatkit::Error.new("You must provide the ID of the user you want to delete")
      end

      @api_instance.request(
        method: "DELETE",
        path: "/users/#{options[:id]}",
        jwt: generate_su_token
      )
    end

    def get_user(options)
      if options[:id].nil?
        raise Chatkit::Error.new("You must provide the ID of the user you want to fetch")
      end

      res = @api_instance.request(
        method: "GET",
        path: "/users/#{options[:id]}",
        jwt: generate_su_token
      )

      JSON.parse(res.body)
    end

    def get_users(options = nil)
      request_options = {
        method: "GET",
        path: "/users",
        jwt: generate_su_token
      }

      unless options.nil?
        request_options.merge!({
          query: {
            from_ts: options[:from_ts],
            limit: options[:limit],
          }
        })
      end

      @api_instance.request(request_options)
    end

    def get_users_by_ids(options)
      if options[:user_ids].nil?
        raise Chatkit::Error.new("You must provide the IDs of the users you want to fetch")
      end

      @api_instance.request(
        method: "GET",
        path: "/users_by_ids",
        query: {
          user_ids: options[:user_ids].join(",")
        },
        jwt: generate_su_token
      )
    end

    # Room API

    def create_room(options)
      if options[:creator_id].nil?
        raise Chatkit::Error.new("You must provide the ID of the user creating the room")
      end

      if options[:name].nil?
        raise Chatkit::Error.new("You must provide a name for the room")
      end

      body = {
        name: options[:name],
        private: options[:private] || false
      }

      unless options[:user_ids].nil?
        body[:user_ids] = options[:user_ids]
      end

      res = @api_instance.request(
        method: "POST",
        path: "/rooms",
        headers: {
          "Content-Type": "application/json",
        },
        body: body,
        jwt: generate_su_token({ user_id: options[:creator_id] })
      )

      JSON.parse(res.body)
    end

    def update_room(options)
      if options[:id].nil?
        raise Chatkit::Error.new("You must provide the ID of the room to update")
      end

      payload = {}
      payload[:name] = options[:name] unless options[:name].nil?
      payload[:private] = options[:private] unless options[:private].nil?

      @api_instance.request(
        method: "PUT",
        path: "/rooms/#{options[:id]}",
        headers: {
          "Content-Type": "application/json",
        },
        body: payload,
        jwt: generate_su_token
      )
    end

    def delete_room(options)
      if options[:id].nil?
        raise Chatkit::Error.new("You must provide the ID of the room to delete")
      end

      @api_instance.request(
        method: "DELETE",
        path: "/rooms/#{options[:id]}",
        headers: {
          "Content-Type": "application/json",
        },
        jwt: generate_su_token
      )
    end

    def get_room(options)
      if options[:id].nil?
        raise Chatkit::Error.new("You must provide the ID of the room to fetch")
      end

      @api_instance.request(
        method: "GET",
        path: "/rooms/#{options[:id]}",
        jwt: generate_su_token
      )
    end

    def get_rooms(options = nil)
      request_options = {
        method: "GET",
        path: "/rooms",
        jwt: generate_su_token
      }

      unless options.nil?
        request_options.merge!({ query: { from_id: options[:from_id] }})
      end

      res = @api_instance.request(request_options)

      JSON.parse(res.body)
    end

    def get_user_rooms(options)
      res = get_rooms_for_user(options)
      JSON.parse(res.body)
    end

    def get_user_joinable_rooms(options)
      options[:joinable] = true
      res = get_rooms_for_user(options)
      JSON.parse(res.body)
    end

    def add_users_to_room(options)
      if options[:room_id].nil?
        raise Chatkit::Error.new("You must provide the ID of the room you want to add users to")
      end

      if options[:user_ids].nil?
        raise Chatkit::Error.new("You must provide a list of IDs of the users you want to add to the room")
      end

      @api_instance.request(
        method: "PUT",
        path: "/rooms/#{options[:room_id]}/users/add",
        headers: {
          "Content-Type": "application/json",
        },
        body: { user_ids: options[:user_ids] },
        jwt: generate_su_token
      )
    end

    def remove_users_from_room(options)
      if options[:room_id].nil?
        raise Chatkit::Error.new("You must provide the ID of the room you want to remove users from")
      end

      if options[:user_ids].nil?
        raise Chatkit::Error.new("You must provide a list of IDs of the users you want to remove from the room")
      end

      @api_instance.request(
        method: "PUT",
        path: "/rooms/#{options[:room_id]}/users/remove",
        headers: {
          "Content-Type": "application/json",
        },
        body: { user_ids: options[:user_ids] },
        jwt: generate_su_token
      )
    end

    # Messages API

    def get_room_messages(options)
      if options[:room_id].nil?
        raise Chatkit::Error.new("You must provide the ID of the room to fetch messages from")
      end

      query_params = {}
      query_params[:initial_id] = options[:initial_id] unless options[:initial_id].nil?
      query_params[:direction] = options[:direction] unless options[:direction].nil?
      query_params[:limit] = options[:limit] unless options[:limit].nil?

      @api_instance.request(
        method: "GET",
        path: "/rooms/#{options[:room_id]}/messages",
        query: query_params,
        jwt: generate_su_token
      )
    end

    def send_message(options)
      if options[:room_id].nil?
        raise Chatkit::Error.new("You must provide the ID of the room to send the message to")
      end

      if options[:sender_id].nil?
        raise Chatkit::Error.new("You must provide the ID of the user sending the message")
      end

      if options[:text].nil?
        raise Chatkit::Error.new("You must provide some text for the message")
      end

      attachment = options[:attachment]

      unless attachment.nil?
        if attachment[:resource_link].nil?
          raise Chatkit::Error.new("You must provide a resource_link for the message attachment")
        end

        valid_file_types = ['image', 'video', 'audio', 'file']

        if attachment[:type].nil? || valid_file_types.include?(attachment[:type])
          raise Chatkit::Error.new(
            "You must provide a valid type for the message attachment, i.e. one of: #{valid_file_types.join(', ')}"
          )
        end
      end

      payload = {
        text: options[:text],
        attachment: options[:attachment]
      }

      @api_instance.request(
        method: "POST",
        path: "/rooms/#{options[:room_id]}/messages",
        body: payload,
        jwt: generate_su_token({ user_id: options[:sender_id] })
      )
    end

    # Roles and permissions API

    def create_global_role(options)
      options[:scope] = GLOBAL_SCOPE
      create_role(options)
    end

    def create_room_role(options)
      options[:scope] = ROOM_SCOPE
      create_role(options)
    end

    def delete_global_role(options)
      options[:scope] = GLOBAL_SCOPE
      delete_role(options)
    end

    def delete_room_role(options)
      options[:scope] = ROOM_SCOPE
      delete_role(options)
    end

    def assign_global_role_to_user(options)
      assign_role_to_user(options)
    end

    def assign_room_role_to_user(options)
      if options[:room_id].nil?
        raise Chatkit::Error.new("You must provide a room ID to assign a room role to a user")
      end

      assign_role_to_user(options)
    end

    def get_roles
      res = @authorizer_instance.request(
        method: "GET",
        path: "/roles",
        jwt: generate_su_token
      )

      JSON.parse(res.body)
    end

    def get_user_roles(options)
      if options[:user_id].nil?
        raise Chatkit::Error.new("You must provide the ID of the user whose rooms you want to fetch")
      end

      res = @authorizer_instance.request(
        method: "GET",
        path: "/users/#{options[:user_id]}/roles",
        jwt: generate_su_token
      )

      JSON.parse(res.body)
    end

    def remove_global_role_for_user(options)
      remove_role_for_user(options)
    end

    def remove_room_role_for_user(options)
      if options[:room_id].nil?
        raise Chatkit::Error.new("You must provide a room ID")
      end

      remove_role_for_user(options)
    end

    def get_permissions_for_global_role(options)
      options[:scope] = GLOBAL_SCOPE
      get_permissions_for_role(options)
    end

    def get_permissions_for_room_role(options)
      options[:scope] = ROOM_SCOPE
      get_permissions_for_role(options)
    end

    def update_permissions_for_global_role(options)
      options[:scope] = GLOBAL_SCOPE
      update_permissions_for_role(options)
    end

    def update_permissions_for_room_role(options)
      options[:scope] = ROOM_SCOPE
      update_permissions_for_role(options)
    end

    # Cursors API

    def get_read_cursor(options)
      if options[:user_id].nil?
        raise Chatkit::Error.new("You must provide the ID of the user whose read cursor you want to fetch")
      end

      if options[:room_id].nil?
        raise Chatkit::Error.new("You must provide the ID of the room that you want the read cursor for")
      end

      res = @cursors_instance.request(
        method: "GET",
        path: "/cursors/0/rooms/#{options[:room_id]}/users/#{options[:user_id]}",
        jwt: generate_su_token
      )

      JSON.parse(res.body)
    end

    def set_read_cursor(options)
      if options[:user_id].nil?
        raise Chatkit::Error.new("You must provide the ID of the user whose read cursor you want to set")
      end

      if options[:room_id].nil?
        raise Chatkit::Error.new("You must provide the ID of the room you want to set the user's cursor in")
      end

      if options[:position].nil?
        raise Chatkit::Error.new("You must provide position of the read cursor")
      end

      res = @cursors_instance.request(
        method: "PUT",
        path: "/cursors/0/rooms/#{options[:room_id]}/users/#{options[:user_id]}",
        body: { position: options[:position] },
        jwt: generate_su_token
      )

      JSON.parse(res.body)
    end

    def get_user_read_cursors(options)
      if options[:user_id].nil?
        raise Chatkit::Error.new("You must provide the ID of the user whose read cursors you want to fetch")
      end

      @cursors_instance.request(
        method: "GET",
        path: "/cursors/0/users/#{options[:user_id]}",
        jwt: generate_su_token
      )
    end

    def get_read_cursors_for_room(options)
      if options[:room_id].nil?
        raise Chatkit::Error.new("You must provide the ID of the room that you want the read cursors for")
      end

      res = @cursors_instance.request(
        method: "GET",
        path: "/cursors/0/rooms/#{options[:room_id]}",
        jwt: generate_su_token
      )

      JSON.parse(res.body)
    end

    # Service-specific helpers

    def api_request(options)
      @api_instance.request(options)
    end

    def authorizer_request(options)
      @authorizer_instance.request(options)
    end

    def cursors_request(options)
      @cursors_instance.request(options)
    end

    private

    def get_rooms_for_user(options)
      if options[:id].nil?
        raise Chatkit::Error.new("You must provide the ID of the user whose rooms you want to fetch")
      end

      request_options = {
        method: "GET",
        path: "/users/#{options[:id]}/rooms",
        jwt: generate_su_token({ user_id: options[:id] })
      }

      unless options[:joinable].nil?
        request_options.merge!({ query: { joinable: options[:joinable] }})
      end

      @api_instance.request(request_options)
    end

    def create_role(options)
      if options[:name].nil?
        raise Chatkit::Error.new("You must provide a name for the role")
      end

      if options[:permissions].nil?
        raise Chatkit::Error.new("You must provide permissions for the role, even if it's an empty list")
      end

      @authorizer_instance.request(
        method: "POST",
        path: "/roles",
        headers: {
          "Content-Type": "application/json"
        },
        body: {
          scope: options[:scope],
          name: options[:name],
          permissions: options[:permissions],
        },
        jwt: generate_su_token
      )
    end

    def delete_role(options)
      if options[:name].nil?
        raise Chatkit::Error.new("You must provide the role's name")
      end

      @authorizer_instance.request(
        method: "DELETE",
        path: "/roles/#{options[:name]}/scope/#{options[:scope]}",
        jwt: generate_su_token
      )
    end

    def assign_role_to_user(options)
      if options[:name].nil?
        raise Chatkit::Error.new("You must provide the role's name")
      end

      if options[:user_id].nil?
        raise Chatkit::Error.new("You must provide the ID of the user you want to assign the role to")
      end

      body = { name: options[:name] }

      unless options[:room_id].nil?
        body.merge!(room_id: options[:room_id])
      end

      @authorizer_instance.request(
        method: "PUT",
        path: "/users/#{options[:user_id]}/roles",
        headers: {
          "Content-Type": "application/json",
        },
        body: body,
        jwt: generate_su_token
      )
    end

    def remove_role_for_user(options)
      if options[:user_id].nil?
        raise Chatkit::Error.new("You must provide the ID of the user you want to remove the role for")
      end

      request_options = {
        method: "DELETE",
        path: "/users/#{options[:user_id]}/roles",
        headers: {
          "Content-Type": "application/json",
        },
        jwt: generate_su_token
      }

      unless options[:room_id].nil?
        request_options.merge!({ query: { room_id: options[:room_id] }})
      end

      @authorizer_instance.request(request_options)
    end

    def get_permissions_for_role(options)
      if options[:name].nil?
        raise Chatkit::Error.new("You must provide the name of the role you want to fetch the permissions of")
      end

      res = @authorizer_instance.request(
        method: "GET",
        path: "/roles/#{options[:name]}/scope/#{options[:scope]}/permissions",
        jwt: generate_su_token
      )

      JSON.parse(res.body)
    end

    def update_permissions_for_role(options)
      if options[:name].nil?
        raise Chatkit::Error.new("You must provide the name of the role you want to update the permissions of")
      end

      permissions_to_add = options[:permissions_to_add]
      permissions_to_remove = options[:permissions_to_remove]

      if permissions_to_add.empty? && permissions_to_remove.empty?
        raise Chatkit::Error.new("permissions_to_add and permissions_to_remove cannot both be empty")
      end

      body = {}
      body[:add_permissions] = permissions_to_add unless permissions_to_add.empty?
      body[:remove_permissions] = permissions_to_remove unless permissions_to_remove.empty?

      @authorizer_instance.request(
        method: "PUT",
        path: "/roles/#{options[:name]}/scope/#{options[:scope]}/permissions",
        headers: {
          "Content-Type": "application/json"
        },
        body: body,
        jwt: generate_su_token
      )
    end
  end
end
