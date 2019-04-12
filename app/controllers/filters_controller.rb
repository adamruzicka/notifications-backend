# frozen_string_literal: true

class FiltersController < ApplicationController
  before_action :find_filter, :only => %i[destroy update show]

  def index
    process_index Filter, FilterSerializer
  end
end
