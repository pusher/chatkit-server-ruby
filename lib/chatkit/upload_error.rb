require_relative './error'

module Chatkit
  class UploadError < Chatkit::Error
    attr_accessor :message, :response_object

    def initialize(error)
      @message = error[:message]
      @response_object = error[:response_object]
    end

    def to_s
      "Chatkit::MissingParameterError - #{@message}"
    end

  end
end
