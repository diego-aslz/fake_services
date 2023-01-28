module FakeServices
  class Stripe
    class Customers < Resource
      attr_writer :fake_card

      def setup
        stub_request(:post, url_for("/v1/customers")).to_return(method(:handle_create))
        stub_request(:post, %r{#{base_url}/v1/customers/\w+}).to_return(method(:handle_update))
        stub_request(:get, %r{#{base_url}/v1/customers/\w+}).to_return(method(:handle_show))
        stub_request(:get, %r{#{base_url}/v1/customers/\w+/sources\?object=card}).to_return(method(:handle_cards_list))
      end

      def fake_card
        @fake_card ||= {
          id: "card-1",
          object: "card",
          brand: "Visa",
          exp_month: 12,
          exp_year: 2030,
          last4: "4242",
        }.freeze
      end

      private

      def build_create_response_body(record)
        super.merge(subscriptions: { data: [] })
      end

      def handle_cards_list(request)
        with_record(request.uri.to_s[%r{customers/(\w+)/sources}, 1]) do |_customer|
          default_response(body: [fake_card].to_json)
        end
      end
    end
  end
end
