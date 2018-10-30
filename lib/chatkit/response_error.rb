require_relative './error'

module Chatkit
  class ResponseError < Chatkit::Error
    attr_reader :status, :headers, :error_description, :error, :error_uri

    def initialize(platform_error)
      @status = platform_error.status
      @headers = platform_error.headers
      @error = platform_error.error
      @error_description = platform_error.error_description
      @error_uri = platform_error.error_uri
    end

    def to_s
      output = "Chatkit::ResponseError - status: #{@status} description: #{@error_description}."
      output += " Find out more at #{@error_uri}" if @error_uri
      output
    end

    def as_json(options = {})
      json = {
        status: @status,
        headers: @headers,
        error: @error,
        error_description: @error_description,
      }
      json[:error_uri] = @error_uri unless @error_uri.nil?
      json
    end

    def to_json(*options)
      as_json(*options).to_json(*options)
    end

  end
end
