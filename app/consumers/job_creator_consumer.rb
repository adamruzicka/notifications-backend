# frozen_string_literal: true

require 'notifications'
require 'dispatcher'

class JobCreatorConsumer < Racecar::Consumer
  subscribes_to Notifications::INCOMING_TOPIC

  def process(kafka_message)
    message_value = kafka_message.value
    Rails.logger.debug("Received message: #{message_value}")

    begin
      message = Message.from_json(message_value)
    rescue ArgumentError => e
      Rails.logger.warn("Encountered #{e.inspect} when processing message #{message_value}, discarding.")
      return
    end

    dispatcher = Dispatcher.new(message)
    dispatcher.dispatch!
  end
end
