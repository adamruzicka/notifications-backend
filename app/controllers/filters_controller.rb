# frozen_string_literal: true

class FiltersController < ApplicationController
  before_action :find_endpoint, :only => %i[show]

  def show
    render :json => FilterSerializer.new(@endpoint.filter)
  end

  private

  def find_endpoint
    @endpoint = authorize Endpoint.find(params.require(:endpoint_id))
  end
end
