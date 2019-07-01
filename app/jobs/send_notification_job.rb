# frozen_string_literal: true

require 'notifications'

# Sends a simple one-step notification.
class SendNotificationJob < SendTestNotificationJob
  def self.disable_endpoint(endpoint)
    endpoint.active = false
    endpoint.save!
  end

  discard_on(Notifications::FatalError) do |job, error|
    endpoint = job.endpoint
    disable_endpoint(endpoint)
    Rails.logger.warn("Disabled #{endpoint} after receiving #{error.inspect}")
  end

  retry_on(Notifications::RecoverableError, wait: :exponentially_longer, attempts: 3) do |job, error|
    endpoint = job.endpoint
    disable_endpoint(endpoint)
    Rails.logger.warn("Disabled #{endpoint} after too many retries for #{error.inspect}")
  end
end
