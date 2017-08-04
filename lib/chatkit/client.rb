require 'pusher-platform'
require 'json'
require_relative './permissions'

class Error < RuntimeError
end

module Chatkit
  class Client
    attr_accessor :api_instance, :authorizer_instance

    def initialize(options)
      base_options = {
        instance: options[:instance],
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

    # User API

    def create_user(id, name)
      @api_instance.request(
        method: "POST",
        path: "/users",
        headers: {
          "Content-Type": "application/json",
        },
        body: {
          id: id,
          name: name,
        },
        jwt: @api_instance.generate_access_token(user_id: id, su: true)
      )
    end

    def delete_user(id)
      @api_instance.request(
        method: "DELETE",
        path: "/users/#{id}",
        jwt: @api_instance.generate_access_token(user_id: id, su: true)
      )
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
        jwt: @api_instance.generate_access_token(su: true)
      )

      JSON.parse(resp.body)
    end

    def get_user_roles(user_id)
      resp = @authorizer_instance.request(
        method: "GET",
        path: "/users/#{user_id}/roles",
        jwt: @api_instance.generate_access_token(su: true)
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

    private

    def create_role(name, scope, permissions)
      permissions.each do |permission|
        unless VALID_PERMISSIONS[:room].include?(permission)
          raise Error("Permission value #{permission} is invalid")
        end
      end

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
        jwt: @api_instance.generate_access_token(su: true)
      )
    end

    def delete_role(role_name, scope)
      @authorizer_instance.request(
        method: "DELETE",
        path: "/roles/#{role_name}/scope/#{scope}",
        jwt: @api_instance.generate_access_token(su: true)
      )
    end

    def assign_role_to_user(user_id, role_name, room_id)
      body = { name: role_name }

      unless room_id.nil?
        body.merge!(room_id: room_id)
      end

      @authorizer_instance.request(
        method: "POST",
        path: "/users/#{user_id}/roles",
        headers: {
          "Content-Type": "application/json",
        },
        body: body,
        jwt: @api_instance.generate_access_token(su: true)
      )
    end

    def remove_role_for_user(user_id, room_id)
      options = {
        method: "PUT",
        path: "/users/#{user_id}/roles",
        headers: {
          "Content-Type": "application/json",
        },
        body: {},
        jwt: @api_instance.generate_access_token(su: true)
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
        jwt: @api_instance.generate_access_token(su: true)
      )

      JSON.parse(resp.body)
    end
  end
end
