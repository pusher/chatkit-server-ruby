require_relative './error'

module Chatkit
  class ParameterTypeError < Chatkit::Error
    attr_accessor :message

    def initialize(message)
      @message = message
    end

    def to_s
      "Chatkit::ParameterTypeError - #{@message}"
    end

  end
end
