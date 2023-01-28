module FakeServices
  class Stripe
    class Resource < SimpleDelegator
      include WebMock::API

      def initialize
        super([])
      end

      protected

      def handle_show(request)
        with_record(request.uri.to_s.split("#{plural_name}/").last) do |record|
          default_response(body: record.to_json)
        end
      end

      def handle_create(request)
        record = Rack::Utils.parse_nested_query(request.body).transform_keys(&:to_sym)
        record[:id] = "#{id_prefix}_#{size + 1}"

        self << record

        default_response(body: build_create_response_body(record).to_json, status: 201)
      end

      def build_create_response_body(record)
        record.merge(object: resource_name)
      end

      def handle_update(request)
        with_record(request.uri.to_s.split("#{plural_name}/").last) do |record|
          record.merge!(Rack::Utils.parse_nested_query(request.body).transform_keys(&:to_sym))

          on_update(record)

          default_response(body: record.to_json)
        end
      end

      def on_update(_record)
        # NOOP
      end

      def find_by_id(id)
        find { |r| r[:id] == id }
      end

      def url_for(path)
        "#{base_url}#{path}"
      end

      def base_url
        "https://api.stripe.com"
      end

      def default_response(body:, status: 200)
        { status: status, body: body, headers: default_headers }
      end

      def default_headers
        { content_type: "application/json" }
      end

      def with_record(id)
        record = find_by_id(id)

        return default_response(status: 404, body: not_found_error(id).to_json) unless record

        yield record
      end

      def not_found_error(id)
        { error: { type: "invalid_request_error", message: "No such #{resource_name}: #{id}", param: "id" } }
      end

      def resource_name
        @resource_name ||= plural_name[0..plural_name.size - 2]
      end

      def plural_name
        @plural_name ||= self.class.to_s.split("::").last.downcase
      end

      def id_prefix
        resource_name[0..2]
      end
    end
  end
end
