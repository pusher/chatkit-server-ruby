require 'pusher-platform'
require 'json'
require_relative './permissions'

module Chatkit

  class Error < RuntimeError
  end

  class Client
    attr_accessor :api_instance, :authorizer_instance

    def initialize(options)
      base_options = {
        locator: options[:instance_locator],
        key: options[:key],
        port: options[:port],
        host: options[:host],
        client: options[:client]
      }

      @api_instance = Pusher::Instance.new(
        base_options.merge!({
          service_name: 'chatkit',
          service_version: 'v1'
        })
      )

      @authorizer_instance = Pusher::Instance.new(
        base_options.merge!({
          service_name: 'chatkit_authorizer',
          service_version: 'v1'
        })
      )
    end

    def authenticate(request, options)
      @api_instance.authenticate(request, options)
    end

    def generate_access_token(options)
      @api_instance.generate_access_token(options)
    end

    # User API

    def create_user(id, name, avatar_url, custom_data)
      body = {
        id: id,
        name: name
      }

      unless avatar_url.nil?
        body[:avatar_url] = avatar_url
      end

      unless custom_data.nil?
        body[:custom_data] = custom_data
      end

      @api_instance.request(
        method: "POST",
        path: "/users",
        headers: {
          "Content-Type": "application/json",
        },
        body: body,
        jwt: generate_access_token(su: true)
      )
    end

    def delete_user(id)
      @api_instance.request(
        method: "DELETE",
        path: "/users/#{id}",
        jwt: generate_access_token(su: true)
      )
    end

    def get_users(from_id)
      request_options = {
        method: "GET",
        path: "/users",
        jwt: generate_access_token(su: true)
      }

      unless from_id == nil && from_id == ""
        request_options.merge!({ query: { from_id: from_id }})
      end

      @api_instance.request(request_options)
    end

    def get_users_by_ids(user_ids)
      @api_instance.request(
        method: "GET",
        path: "/users_by_ids",
        query: {
          user_ids: user_ids.join(",")
          },
        jwt: generate_access_token(su: true)
      )
    end

    # Room API

    def get_room(room_id)
      @api_instance.request(
        method: "GET",
        path: "/rooms/#{room_id}",
        jwt: generate_access_token(su: true)
      )
    end

    def get_room_messages(room_id, initial_id, direction, limit)
      query_params = {}

      query_params[:initial_id] = initial_id unless initial_id.nil?
      query_params[:direction] = direction unless direction.nil?
      query_params[:limit] = limit unless limit.nil?

      @api_instance.request(
        method: "GET",
        path: "/rooms/#{room_id}/messages",
        query: query_params,
        jwt: @api_instance.generate_access_token(su: true)
      )
    end

    def get_rooms(from_id)
      request_options = {
        method: "GET",
        path: "/rooms",
        jwt: @api_instance.generate_access_token(su: true)
      }

      unless from_id == nil && from_id == ""
        request_options.merge!({ query: { from_id: from_id }})
      end

      @api_instance.request(request_options)
    end

    # Authorizer API

    def create_room_role(name, permissions)
      create_role(name, ROOM_SCOPE, permissions)
    end

    def create_global_role(name, permissions)
      create_role(name, GLOBAL_SCOPE, permissions)
    end

    def delete_room_role(role_name)
      delete_role(role_name, ROOM_SCOPE)
    end

    def delete_global_role(role_name)
      delete_role(role_name, GLOBAL_SCOPE)
    end

    def assign_global_role_to_user(user_id, role_name)
      assign_role_to_user(user_id, role_name, nil)
    end

    def assign_room_role_to_user(user_id, role_name, room_id)
      assign_role_to_user(user_id, role_name, room_id)
    end

    def get_roles
      resp = @authorizer_instance.request(
        method: "GET",
        path: "/roles",
        jwt: generate_access_token(su: true)
      )

      JSON.parse(resp.body)
    end

    def get_user_roles(user_id)
      resp = @authorizer_instance.request(
        method: "GET",
        path: "/users/#{user_id}/roles",
        jwt: generate_access_token(su: true)
      )

      JSON.parse(resp.body)
    end

    def remove_global_role_for_user(user_id)
      remove_role_for_user(user_id, nil)
    end

    def remove_room_role_for_user(user_id, room_id)
      remove_role_for_user(user_id, room_id)
    end

    def get_permissions_for_global_role(role_name)
      get_permissions_for_role(role_name, GLOBAL_SCOPE)
    end

    def get_permissions_for_room_role(role_name)
      get_permissions_for_role(role_name, ROOM_SCOPE)
    end

    def update_role_permissions(role_name, scope, permissions_to_add, permissions_to_remove)
      check_permissions(permissions_to_add+permissions_to_remove)

      if permissions_to_add.empty? && permissions_to_remove.empty?
        raise Chatkit::Error.new("permissions_to_add and permissions_to_remove cannot both be empty")
      end

      body = {}
      body[:add_permissions] = permissions_to_add unless permissions_to_add.empty?
      body[:remove_permissions] = permissions_to_remove unless permissions_to_remove.empty?

      @authorizer_instance.request(
        method: "PUT",
        path: "/roles/#{role_name}/scope/#{scope}/permissions",
        headers: {
          "Content-Type": "application/json"
        },
        body: body,
        jwt: generate_access_token(su: true)
      )
    end

    private

    def create_role(name, scope, permissions)
      check_permissions(permissions)

      @authorizer_instance.request(
        method: "POST",
        path: "/roles",
        headers: {
          "Content-Type": "application/json"
        },
        body: {
          scope: scope,
          name: name,
          permissions: permissions,
        },
        jwt: generate_access_token(su: true)
      )
    end

    def delete_role(role_name, scope)
      @authorizer_instance.request(
        method: "DELETE",
        path: "/roles/#{role_name}/scope/#{scope}",
        jwt: generate_access_token(su: true)
      )
    end

    def assign_role_to_user(user_id, role_name, room_id)
      body = { name: role_name }

      unless room_id.nil?
        body.merge!(room_id: room_id)
      end

      @authorizer_instance.request(
        method: "PUT",
        path: "/users/#{user_id}/roles",
        headers: {
          "Content-Type": "application/json",
        },
        body: body,
        jwt: generate_access_token(su: true)
      )
    end

    def remove_role_for_user(user_id, room_id)
      options = {
        method: "DELETE",
        path: "/users/#{user_id}/roles",
        headers: {
          "Content-Type": "application/json",
        },
        query: { room_id: room_id },
        jwt: generate_access_token(su: true)
      }

      unless room_id.nil?
        options.merge!(body: { room_id: room_id })
      end

      @authorizer_instance.request(options)
    end

    def get_permissions_for_role(role_name, scope)
      resp = @authorizer_instance.request(
        method: "GET",
        path: "/roles/#{role_name}/scope/#{scope}/permissions",
        jwt: generate_access_token(su: true)
      )

      JSON.parse(resp.body)
    end

    def check_permissions(permissions)
      permissions.each do |permission|
        unless VALID_PERMISSIONS[scope.to_sym].include?(permission)
          raise Chatkit::Error.new("Permission value #{permission} is invalid")
        end
      end
    end
  end
end
