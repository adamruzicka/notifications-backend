# frozen_string_literal: true

class EndpointsController < ApplicationController
  before_action :find_endpoint, :only => %i[destroy show update]

  def index
    records = paginate(policy_scope(Endpoint))
    render :json => EndpointSerializer.new(records)
  end

  def show
    render :json => EndpointSerializer.new(@endpoint)
  end

  def destroy
    @endpoint.destroy!
    head :no_content
  end

  def create
    begin
      endpoint = build_endpoint
    rescue ActiveRecord::RecordNotFound => ex
      render_unprocessable_entity ex
      return
    end

    authorize endpoint
    process_create endpoint, EndpointSerializer
  end

  def update
    correct_filter_count(nested_filters.count, @endpoint.filters.count)
    @endpoint.filters.zip(nested_filters).each do |(filter, filter_params)|
      filter.update(filter_params)
    end
    process_update(@endpoint, endpoint_params, EndpointSerializer)
  end

  private

  def correct_filter_count(requested, present)
    if requested < present
      @endpoint.filters.limit(present - requested).destroy_all
    elsif requested > present
      (requested - present).times do
        @endpoint.filters.build(account: current_user.account, endpoints: [@endpoint])
      end
    end
  end

  def find_endpoint
    @endpoint = authorize Endpoint.find(params[:id])
  end

  def nested_filters
    params.require(:endpoint).permit(filters: [filter_properties]).fetch(:filters, [])
  end

  def build_filter_attributes(filter_params)
    filter_params.merge(account: current_user.account)
  end

  def build_endpoint
    endpoint = Endpoint.new(endpoint_params)
    endpoint.account = current_user.account
    endpoint.type ||= Endpoint.name

    nested_filters.each do |filter_params|
      authorize(endpoint.filters.build(build_filter_attributes(filter_params)))
    end
    endpoint
  end
end
