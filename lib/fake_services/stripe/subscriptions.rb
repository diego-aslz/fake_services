module FakeServices
  class Stripe
    class Subscriptions < Resource
      def setup
        stub_request(:get, %r{#{base_url}/v1/subscriptions/\w+}).to_return(method(:handle_show))
        stub_request(:post, url_for("/v1/subscriptions")).to_return(method(:handle_create))
        stub_request(:post, %r{#{base_url}/v1/subscriptions/\w+}).to_return(method(:handle_update))
        stub_request(:get, %r{#{base_url}/v1/subscription_items\?subscription=\w+}).to_return(method(:handle_items_list))
        stub_request(:post, %r{#{base_url}/v1/subscription_items/\w+}).to_return(method(:handle_item_update))
      end

      private

      def on_update(subscription)
        subscription[:cancel_at] ||= (Time.now + one_week).to_i if subscription[:cancel_at_period_end] == "true"
      end

      def one_week
        7 * 24 * 60 * 60
      end

      def handle_items_list(request)
        with_record(request.uri.to_s[/\?subscription=(\w+)/, 1]) do |subscription|
          item = build_fake_subscription_item(subscription[:id])

          default_response(body: { object: "list", data: [item] }.to_json)
        end
      end

      def handle_item_update(request)
        with_record(request.uri.to_s[%r{/subscription_items/(\w+)}, 1].gsub(/--item\z/, "")) do |subscription|
          update = Rack::Utils.parse_nested_query(request.body).transform_keys(&:to_sym)
          subscription.merge!(plan: update[:price])

          default_response(body: build_fake_subscription_item(subscription_id).to_json)
        end
      end

      def build_fake_subscription_item(subscription_id)
        {
          id: "#{subscription_id}--item",
          subscription: subscription_id,
          object: "subscription_item",
        }
      end
    end
  end
end
