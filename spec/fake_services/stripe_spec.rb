require "spec_helper"

require "fake_services/stripe"
require "stripe"

Stripe.api_key = "TESTKEY"

RSpec.describe FakeServices::Stripe do
  let(:fake_stripe) { described_class.new }

  before do
    fake_stripe.setup
  end

  shared_examples "a resource" do
    it "handles creation" do
      stripe_class.create(test_record)

      expect(fake_collection.size).to eq(1)
      expect(fake_collection.first.slice(*test_record.keys)).to eq(test_record)
    end

    it "handles update" do
      test_record[:id] = "rec_1"
      fake_collection << test_record.slice(:id)

      stripe_class.update(test_record[:id], test_record)

      expect(fake_collection.size).to eq(1)
      expect(fake_collection.first.slice(*test_record.keys)).to eq(test_record)
    end

    context "when trying to update a non-existent record" do
      it "returns an error" do
        expect { stripe_class.update("1", {}) }.to raise_error(
          Stripe::InvalidRequestError, "No such #{resource_name}: 1"
        )
      end
    end

    it "assigns an ID to it" do
      stripe_class.create(test_record)

      expect(fake_collection.first[:id]).to be_a(String)
    end

    it "allows to set predefined records and handles retrieval" do
      id = "rec_1"
      fake_collection << test_record.merge(id: id)

      record = stripe_class.retrieve(id)

      expect(record.to_h.slice(*test_record.keys)).to eq(test_record)
    end

    it "returns not found for invalid IDs" do
      expect { stripe_class.retrieve("1") }.to raise_error(Stripe::InvalidRequestError, "No such #{resource_name}: 1")
    end
  end

  describe "customers" do
    it_behaves_like "a resource" do
      let(:test_record) { { email: "john@test.com" } }
      let(:stripe_class) { Stripe::Customer }
      let(:resource_name) { "customer" }
      let(:fake_collection) { fake_stripe.customers }
    end

    it "handles listing cards" do

    end
  end

  describe "subscriptions" do
    it_behaves_like "a resource" do
      let(:test_record) { { customer: "cus_1" } }
      let(:stripe_class) { Stripe::Subscription }
      let(:resource_name) { "subscription" }
      let(:fake_collection) { fake_stripe.subscriptions }
    end

    it "sets a cancellation time when flagging to cancel at period end" do
      fake_stripe.subscriptions << { id: "sub_1" }

      Stripe::Subscription.update("sub_1", cancel_at_period_end: "true")

      expect(fake_stripe.subscriptions.last[:cancel_at]).not_to eq(nil)
    end
  end
end
