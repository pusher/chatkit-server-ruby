require_relative './error'

module Chatkit
  class MissingParameterError < Chatkit::Error
    attr_accessor :message

    def initialize(message)
      @message = message
    end

    def to_s
      "Chatkit::MissingParameterError - #{@message}"
    end

  end
end
