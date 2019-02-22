# frozen_string_literal: true

module Builder
  class App
    def event_types
      @event_types ||= []
    end

    def event_type(name)
      @event_types ||= []
      @event_types << name
    end

    # rubocop:disable Style/TrivialAccessors
    def name(name)
      @name = name
    end
    # rubocop:enable Style/TrivialAccessors

    def build!
      app = ::App.new(:name => @name, :title => @name)
      app.save!
      event_types.each_with_index do |type, index|
        app.event_types.create(:name => type, :title => type, :external_id => index.to_s)
      end
      app
    end

    def self.build!
      builder = App.new
      yield builder
      builder.build!
    end
  end
end
