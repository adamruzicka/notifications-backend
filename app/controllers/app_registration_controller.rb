# frozen_string_literal: true

class AppRegistrationController < ActionController::API
  def create
    # TODO: Handle auth
    ActiveRecord::Base.transaction do
      app = App.find_or_initialize_by(:name => app_params[:name])
      app.update_attributes!(app_params.slice(:title))
      set_event_types(app, params[:event_types])
      render :json => AppSerializer.new(app)
    end
  end

  private

  def set_event_types(app, types)
    remove_obsolete(app.event_types, types.map { |type| type[:id] })
    types.each do |type|
      event_type = find_or_update(app.event_types, type)
      set_levels(event_type, type[:levels])
    end
  end

  def set_levels(event_type, levels)
    remove_obsolete(event_type.levels, levels.map { |level| level[:id] })
    levels.each do |level|
      find_or_update(event_type.levels, level)
    end
  end

  def find_or_update(scope, params)
    thing = scope.find_or_initialize_by(:external_id => params[:id])
    thing.update_attributes(params.permit(:name, :title).slice(:name, :title))
    thing
  end

  def remove_obsolete(scope, wanted_ids)
    scope.where.not(:external_id => wanted_ids).destroy_all
  end

  def app_params
    params.require(:application).permit(:name, :title)
  end
end
