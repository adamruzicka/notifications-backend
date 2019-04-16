# frozen_string_literal: true

class FiltersController < ApplicationController
  def index
    process_index Filter, FilterSerializer
  end
end
