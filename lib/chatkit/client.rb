require 'pusher-platform'
require 'json'
require 'cgi'
require 'excon'

require_relative './error'
require_relative './missing_parameter_error'
require_relative './response_error'
require_relative './upload_error'

module Chatkit

  ROOM_SCOPE = "room"
  GLOBAL_SCOPE = "global"

  class Client
    attr_accessor :api_instance,
                  :api_v2_instance,
                  :authorizer_instance,
                  :cursors_instance

    def initialize(options)
      base_options = {
        locator: options[:instance_locator],
        key: options[:key],
        port: options[:port],
        host: options[:host],
        client: options[:client],
        sdk_info: PusherPlatform::SDKInfo.new({
          product_name: 'chatkit',
          version: '0.7.2'
        })
      }

      @api_v2_instance = PusherPlatform::Instance.new(
        base_options.merge({
          service_name: 'chatkit',
          service_version: 'v2'
        })
      )

      @api_instance = PusherPlatform::Instance.new(
        base_options.merge({
          service_name: 'chatkit',
          service_version: 'v3'
        })
      )

      @authorizer_instance = PusherPlatform::Instance.new(
        base_options.merge({
          service_name: 'chatkit_authorizer',
          service_version: 'v2'
        })
      )

      @cursors_instance = PusherPlatform::Instance.new(
        base_options.merge({
          service_name: 'chatkit_cursors',
          service_version: 'v2'
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

    def generate_access_token(options)
      if options.empty?
        raise Chatkit::Error.new("You must provide a either a user_id or `su: true`")
      end

      @api_instance.generate_access_token(options)
    end

    def generate_su_token(options = {})
      generate_access_token({ su: true }.merge(options))
    end

    # User API

    def create_user(options)
      if options[:id].nil?
        raise Chatkit::MissingParameterError.new("You must provide an ID for the user you want to create")
      end

      if options[:name].nil?
        raise Chatkit::MissingParameterError.new("You must provide a name for the user you want to create")
      end

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

      api_request({
        method: "POST",
        path: "/users",
        body: body,
        jwt: generate_su_token[:token]
      })
    end

    def create_users(options)
      if options[:users].nil?
        raise Chatkit::MissingParameterError.new("You must provide a list of users that you want to create")
      end

      api_request({
        method: "POST",
        path: "/batch_users",
        body: options,
        jwt: generate_su_token[:token]
      })
    end

    def update_user(options)
      if options[:id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the user you want to update")
      end

      payload = {}
      payload[:name] = options[:name] unless options[:name].nil?
      payload[:avatar_url] = options[:avatar_url] unless options[:avatar_url].nil?
      payload[:custom_data] = options[:custom_data] unless options[:custom_data].nil?

      api_request({
        method: "PUT",
        path: "/users/#{CGI::escape options[:id]}",
        body: payload,
        jwt: generate_su_token({ user_id: options[:id] })[:token]
      })
    end

    def delete_user(options)
      if options[:id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the user you want to delete")
      end

      api_request({
        method: "DELETE",
        path: "/users/#{CGI::escape options[:id]}",
        jwt: generate_su_token[:token]
      })
    end

    def get_user(options)
      if options[:id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the user you want to fetch")
      end

      api_request({
        method: "GET",
        path: "/users/#{CGI::escape options[:id]}",
        jwt: generate_su_token[:token]
      })
    end

    def get_users(options = nil)
      request_options = {
        method: "GET",
        path: "/users",
        jwt: generate_su_token[:token]
      }

      unless options.nil?
        query = {}
        query[:from_ts] = options[:from_timestamp] unless options[:from_timestamp].nil?
        query[:limit] = options[:limit] unless options[:limit].nil?

        request_options.merge!({
          query: query
        })
      end

      api_request(request_options)
    end

    def get_users_by_id(options)
      if options[:user_ids].nil?
        raise Chatkit::MissingParameterError.new("You must provide the IDs of the users you want to fetch")
      end

      api_request({
        method: "GET",
        path: "/users_by_ids",
        query: {
          id: options[:user_ids],
        },
        jwt: generate_su_token[:token]
      })
    end

    # Room API

    def create_room(options)
      if options[:creator_id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the user creating the room")
      end

      if options[:name].nil?
        raise Chatkit::MissingParameterError.new("You must provide a name for the room")
      end

      body = {
        name: options[:name],
        private: options[:private] || false
      }

      body[:custom_data] = options[:custom_data] unless options[:custom_data].nil?

      unless options[:user_ids].nil?
        body[:user_ids] = options[:user_ids]
      end

      api_request({
        method: "POST",
        path: "/rooms",
        body: body,
        jwt: generate_su_token({ user_id: options[:creator_id] })[:token]
      })
    end

    def update_room(options)
      if options[:id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the room to update")
      end

      payload = {}
      payload[:name] = options[:name] unless options[:name].nil?
      payload[:private] = options[:private] unless options[:private].nil?
      payload[:custom_data] = options[:custom_data] unless options[:custom_data].nil?

      api_request({
        method: "PUT",
        path: "/rooms/#{CGI::escape options[:id]}",
        body: payload,
        jwt: generate_su_token[:token]
      })
    end

    def delete_room(options)
      if options[:id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the room to delete")
      end

      api_request({
        method: "DELETE",
        path: "/rooms/#{CGI::escape options[:id]}",
        jwt: generate_su_token[:token]
      })
    end

    def get_room(options)
      if options[:id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the room to fetch")
      end

      api_request({
        method: "GET",
        path: "/rooms/#{CGI::escape options[:id]}",
        jwt: generate_su_token[:token]
      })
    end

    def get_rooms(options = nil)
      request_options = {
        method: "GET",
        path: "/rooms",
        jwt: generate_su_token[:token]
      }

      unless options.nil?
        query = {}
        query[:include_private] = !options[:include_private].nil? ? options[:include_private] : false
        query[:from_id] = options[:from_id] unless options[:from_id].nil?

        request_options.merge!({
          query: query
        })
      end

      api_request(request_options)
    end

    def get_user_rooms(options)
      get_rooms_for_user(options)
    end

    def get_user_joinable_rooms(options)
      options[:joinable] = true
      get_rooms_for_user(options)
    end

    def add_users_to_room(options)
      if options[:room_id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the room you want to add users to")
      end

      if options[:user_ids].nil?
        raise Chatkit::MissingParameterError.new("You must provide a list of IDs of the users you want to add to the room")
      end

      api_request({
        method: "PUT",
        path: "/rooms/#{CGI::escape options[:room_id]}/users/add",
        body: { user_ids: options[:user_ids] },
        jwt: generate_su_token[:token]
      })
    end

    def remove_users_from_room(options)
      if options[:room_id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the room you want to remove users from")
      end

      if options[:user_ids].nil?
        raise Chatkit::MissingParameterError.new("You must provide a list of IDs of the users you want to remove from the room")
      end

      api_request({
        method: "PUT",
        path: "/rooms/#{CGI::escape options[:room_id]}/users/remove",
        body: { user_ids: options[:user_ids] },
        jwt: generate_su_token[:token]
      })
    end

    # Messages API

    def fetch_multipart_messages(options)
      verify({
        room_id: "You must provide the ID of the room to send the message to",
      }, options)

      if !options[:limit].nil? and options[:limit] <= 0
        raise Chatkit::MissingParameterError.new("Limit must be greater than 0")
      end

      optional_params = [:initial_id, :direction, :limit]
      query_params = options.select { |key,_| optional_params.include? key }

      api_request({
        method: "GET",
        path: "/rooms/#{CGI::escape options[:room_id]}/messages",
        query: query_params,
        jwt: generate_su_token[:token]
      })
    end

    def get_room_messages(options)
      if options[:room_id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the room to fetch messages from")
      end

      query_params = {}
      query_params[:initial_id] = options[:initial_id] unless options[:initial_id].nil?
      query_params[:direction] = options[:direction] unless options[:direction].nil?
      query_params[:limit] = options[:limit] unless options[:limit].nil?

      api_v2_request({
        method: "GET",
        path: "/rooms/#{CGI::escape options[:room_id]}/messages",
        query: query_params,
        jwt: generate_su_token[:token]
      })
    end

    def send_simple_message(options)
      verify({text: "You must provide some text for the message",
             }, options)

      options[:parts] = [{type: "text/plain",
                          content: options[:text]
                         }]

      send_multipart_message(options)
    end

    def send_multipart_message(options)
      verify({
        room_id: "You must provide the ID of the room to send the message to",
        sender_id: "You must provide the ID of the user sending the message",
        parts: "You must provide a parts array",
      }, options)

      if not options[:parts].length > 0
        raise Chatkit::MissingParameterError.new("parts array must have at least one item")
      end

      # this assumes the token lives long enough to finish all S3 uploads
      token = generate_su_token({ user_id: options[:sender_id] })[:token]

      request_parts = options[:parts].map { |part|
        verify({type: "Each part must define a type"}, part)

        if !part[:content].nil?
          {
            type: part[:type],
            content: part[:content]
          }
        elsif !part[:url].nil?
          {
            type: part[:type],
            url: part[:url]
          }
        elsif !part[:file].nil?
          attachment_id = upload_attachment(token, options[:room_id], part)
          {
            type: part[:type],
            attachment: {id: attachment_id},
            name: part[:name],
            customData: part[:customData]
          }.reject{ |_,v| v.nil? }
        else
          raise Chatkit::MissingParameterError.new("Each part must have one of :file, :content or :url")
        end
      }

      api_request({
        method: "POST",
        path: "/rooms/#{CGI::escape options[:room_id]}/messages",
        body: {parts: request_parts},
        jwt: token
      })
    end

    def send_message(options)
      if options[:room_id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the room to send the message to")
      end

      if options[:sender_id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the user sending the message")
      end

      if options[:text].nil?
        raise Chatkit::MissingParameterError.new("You must provide some text for the message")
      end

      attachment = options[:attachment]

      unless attachment.nil?
        if attachment[:resource_link].nil?
          raise Chatkit::MissingParameterError.new("You must provide a resource_link for the message attachment")
        end

        valid_file_types = ['image', 'video', 'audio', 'file']

        if attachment[:type].nil? || !valid_file_types.include?(attachment[:type])
          raise Chatkit::MissingParameterError.new(
            "You must provide a valid type for the message attachment, i.e. one of: #{valid_file_types.join(', ')}"
          )
        end
      end

      payload = {
        text: options[:text],
        attachment: options[:attachment]
      }

      api_v2_request({
        method: "POST",
        path: "/rooms/#{CGI::escape options[:room_id]}/messages",
        body: payload,
        jwt: generate_su_token({ user_id: options[:sender_id] })[:token]
      })
    end

    def delete_message(options)
      if options[:id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the message you want to delete")
      end

      api_request({
        method: "DELETE",
        path: "/messages/#{options[:id]}",
        jwt: generate_su_token[:token]
      })
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
        raise Chatkit::MissingParameterError.new("You must provide a room ID to assign a room role to a user")
      end

      assign_role_to_user(options)
    end

    def get_roles
      authorizer_request({
        method: "GET",
        path: "/roles",
        jwt: generate_su_token[:token]
      })
    end

    def get_user_roles(options)
      if options[:user_id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the user whose roles you want to fetch")
      end

      authorizer_request({
        method: "GET",
        path: "/users/#{CGI::escape options[:user_id]}/roles",
        jwt: generate_su_token[:token]
      })
    end

    def remove_global_role_for_user(options)
      remove_role_for_user(options)
    end

    def remove_room_role_for_user(options)
      if options[:room_id].nil?
        raise Chatkit::MissingParameterError.new("You must provide a room ID")
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
        raise Chatkit::MissingParameterError.new("You must provide the ID of the user whose read cursor you want to fetch")
      end

      if options[:room_id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the room that you want the read cursor for")
      end

      cursors_request({
        method: "GET",
        path: "/cursors/0/rooms/#{CGI::escape options[:room_id]}/users/#{CGI::escape options[:user_id]}",
        jwt: generate_su_token[:token]
      })
    end

    def set_read_cursor(options)
      if options[:user_id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the user whose read cursor you want to set")
      end

      if options[:room_id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the room you want to set the user's cursor in")
      end

      if options[:position].nil?
        raise Chatkit::MissingParameterError.new("You must provide position of the read cursor")
      end

      cursors_request({
        method: "PUT",
        path: "/cursors/0/rooms/#{CGI::escape options[:room_id]}/users/#{CGI::escape options[:user_id]}",
        body: { position: options[:position] },
        jwt: generate_su_token[:token]
      })
    end

    def get_user_read_cursors(options)
      if options[:user_id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the user whose read cursors you want to fetch")
      end

      cursors_request({
        method: "GET",
        path: "/cursors/0/users/#{CGI::escape options[:user_id]}",
        jwt: generate_su_token[:token]
      })
    end

    def get_room_read_cursors(options)
      if options[:room_id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the room that you want the read cursors for")
      end

      cursors_request({
        method: "GET",
        path: "/cursors/0/rooms/#{CGI::escape options[:room_id]}",
        jwt: generate_su_token[:token]
      })
    end

    # Service-specific helpers

    def api_v2_request(options)
      make_request(@api_v2_instance, options)
    end

    def api_request(options)
      make_request(@api_instance, options)
    end

    def authorizer_request(options)
      make_request(@authorizer_instance, options)
    end

    def cursors_request(options)
      make_request(@cursors_instance, options)
    end

    private

    def make_request(instance, options)
      options.merge!({ headers: { "Content-Type": "application/json" } })
      begin
        format_response(instance.request(options))
      rescue PusherPlatform::ErrorResponse => e
        raise Chatkit::ResponseError.new(e)
      rescue PusherPlatform::Error => e
        raise Chatkit::Error.new(e.message)
      end
    end

    def format_response(res)
      body = res.body.empty? ? nil : JSON.parse(res.body, { symbolize_names: true })

      {
        status: res.status,
        headers: res.headers,
        body: body
      }
    end

    def get_rooms_for_user(options)
      if options[:id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the user whose rooms you want to fetch")
      end

      request_options = {
        method: "GET",
        path: "/users/#{CGI::escape options[:id]}/rooms",
        jwt: generate_su_token[:token]
      }

      unless options[:joinable].nil?
        request_options.merge!({ query: { joinable: options[:joinable] }})
      end

      api_request(request_options)
    end

    def create_role(options)
      if options[:name].nil?
        raise Chatkit::MissingParameterError.new("You must provide a name for the role")
      end

      if options[:permissions].nil?
        raise Chatkit::MissingParameterError.new("You must provide permissions for the role, even if it's an empty list")
      end

      authorizer_request({
        method: "POST",
        path: "/roles",
        body: {
          scope: options[:scope],
          name: options[:name],
          permissions: options[:permissions],
        },
        jwt: generate_su_token[:token]
      })
    end

    def delete_role(options)
      if options[:name].nil?
        raise Chatkit::MissingParameterError.new("You must provide the role's name")
      end

      authorizer_request({
        method: "DELETE",
        path: "/roles/#{CGI::escape options[:name]}/scope/#{options[:scope]}",
        jwt: generate_su_token[:token]
      })
    end

    def assign_role_to_user(options)
      if options[:name].nil?
        raise Chatkit::MissingParameterError.new("You must provide the role's name")
      end

      if options[:user_id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the user you want to assign the role to")
      end

      body = { name: options[:name] }

      unless options[:room_id].nil?
        body.merge!(room_id: options[:room_id])
      end

      authorizer_request({
        method: "PUT",
        path: "/users/#{CGI::escape options[:user_id]}/roles",
        body: body,
        jwt: generate_su_token[:token]
      })
    end

    def remove_role_for_user(options)
      if options[:user_id].nil?
        raise Chatkit::MissingParameterError.new("You must provide the ID of the user you want to remove the role for")
      end

      request_options = {
        method: "DELETE",
        path: "/users/#{CGI::escape options[:user_id]}/roles",
        jwt: generate_su_token[:token]
      }

      unless options[:room_id].nil?
        request_options.merge!({ query: { room_id: options[:room_id] }})
      end

      authorizer_request(request_options)
    end

    def get_permissions_for_role(options)
      if options[:name].nil?
        raise Chatkit::MissingParameterError.new("You must provide the name of the role you want to fetch the permissions of")
      end

      authorizer_request({
        method: "GET",
        path: "/roles/#{CGI::escape options[:name]}/scope/#{options[:scope]}/permissions",
        jwt: generate_su_token[:token]
      })
    end

    def update_permissions_for_role(options)
      if options[:name].nil?
        raise Chatkit::MissingParameterError.new("You must provide the name of the role you want to update the permissions of")
      end

      permissions_to_add = options[:permissions_to_add]
      permissions_to_remove = options[:permissions_to_remove]

      if (permissions_to_add.nil? || permissions_to_add.empty?) && (permissions_to_remove.nil? || permissions_to_remove.empty?)
        raise Chatkit::MissingParameterError.new("permissions_to_add and permissions_to_remove cannot both be empty")
      end

      body = {}
      body[:add_permissions] = permissions_to_add unless permissions_to_add.nil? || permissions_to_add.empty?
      body[:remove_permissions] = permissions_to_remove unless permissions_to_remove.nil? ||permissions_to_remove.empty?

      authorizer_request({
        method: "PUT",
        path: "/roles/#{CGI::escape options[:name]}/scope/#{options[:scope]}/permissions",
        body: body,
        jwt: generate_su_token[:token]
      })
    end

    def upload_attachment(token, room_id, part)
      body = part[:file]
      content_length = body.length

      if content_length <= 0
        raise Chatkit::MissingParameterError.new("File contents size must be greater than 0")
      end

      attachment_req = {
        content_type: part[:type],
        content_length: content_length
      }

      attachment_response = api_request({
        method: "POST",
        path: "/rooms/#{CGI::escape room_id}/attachments",
        body: attachment_req,
        jwt: token
      })

      url = attachment_response[:body][:upload_url]
      connection = Excon.new(url, :omit_default_port => true)
      upload_response = connection.put(:body => body)

      if upload_response.status != 200
        error = {message: "Failed to upload attachment",
                 response_object: upload_response
                }
        raise Chatkit::UploadError.new(error)
      end

      attachment_response[:body][:attachment_id]
    end

    def verify(required, options)
      required.each { |field_name, message|
        if options[field_name].nil?
          raise Chatkit::MissingParameterError.new(message)
        end
      }
    end
  end
end
