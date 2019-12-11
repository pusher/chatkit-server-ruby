require_relative './error'

module Chatkit
  class UnexpectedParameterError < Chatkit::Error
    attr_accessor :message

    def initialize(message)
      @message = message
    end

    def to_s
      "Chatkit::UnexpectedParameterError - #{@message}"
    end

  end
end
