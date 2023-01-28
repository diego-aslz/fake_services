require "rack"
require "delegate"

require_relative "stripe/resource"

require_relative "stripe/customers"
require_relative "stripe/subscriptions"

module FakeServices
  class Stripe
    include WebMock::API

    attr_reader :customers, :subscriptions

    def initialize
      @customers = Customers.new
      @subscriptions = Subscriptions.new
    end

    # Stubs HTTP calls to Stripe
    def setup
      customers.setup
      subscriptions.setup
    end
  end
end

# Before('@Stripe') do
#   fake_stripe.setup
# end

# After do
#   reset_fake_stripe
# end

# module FakeStripeHelpers
#   def fake_stripe
#     @fake_stripe ||= FakeStripeServer.new
#   end

#   def reset_fake_stripe
#     @fake_stripe = nil
#   end
# end

# World(FakeStripeHelpers)
