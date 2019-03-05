# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe EndpointsController do
  describe '#update' do
    before do
      @app = Builder::App.build! do |app|
        app.name 'application'
        levels = %w[low medium high]
        5.times do |i|
          app.event_type("event-type-#{i}").levels(levels)
        end
      end
    end
    let(:endpoint) { FactoryBot.create(:endpoint, :account => account) }
    let(:app_ids) { [@app.id] }
    let(:event_types) { @app.event_types.limit(2) }
    let(:level_ids) { event_types.first.levels.pluck(:id) }

    let(:update_params) do
      filter = {
        :app_ids => app_ids,
        :event_type_ids => event_types.pluck(:id),
        :level_ids => level_ids
      }

      { :id => endpoint.id, :endpoint => { :filters => [filter] } }
    end

    def update_endpoint!
      request.headers['X-RH-IDENTITY'] = encoded_header
      put :update, :params => update_params
      expect(response.code).to eq('200')
    end

    it 'creates filters if missing' do
      endpoint
      expect(endpoint.filters.count).to be_zero
      update_endpoint!
      expect(endpoint.reload.filters.count).to eq(1)
    end

    it 'destroys superfluous filters' do
      5.times { endpoint.filters.create(:account => account) }
      expect(endpoint.filters.count).to eq(5)
      update_endpoint!
      expect(endpoint.reload.filters.count).to eq(1)
    end

    it 'updates existing filters' do
      app = FactoryBot.create(:app, :with_event_type)
      # endpoint.filters.create(:account => account, :app_ids => [@app.i
      endpoint.filters.create(
        :account => account,
        :app_ids => [app.id],
        :event_type_ids => app.event_types.pluck(:id),
        :level_ids => app.event_types.map { |type| type.levels.pluck(:id) }.flatten
      )

      expect(endpoint.filters.count).to eq(1)
      update_endpoint!
      expect(endpoint.reload.filters.count).to eq(1)
      filter = endpoint.filters.first
      expect(filter.app_ids).to match(app_ids)
      expect(filter.event_type_ids).to match(event_types.pluck(:id))
      expect(filter.level_ids).to match(level_ids)
    end
  end
end
# rubocop:enable Metrics/BlockLength
