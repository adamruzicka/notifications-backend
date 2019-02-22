# frozen_string_literal: true

module Builder
  class App
    def event_types
      @event_types ||= []
    end

    def event_type(name)
      @event_types ||= []
      type = EventType.new(name)
      @event_types << type
      type
    end

    # rubocop:disable Style/TrivialAccessors
    def name(name)
      @name = name
    end
    # rubocop:enable Style/TrivialAccessors

    def build!
      app = ::App.new(:name => @name, :title => @name)
      app.save!
      event_types.each do |builder|
        builder.build!(app)
      end
      app
    end

    def self.build!
      builder = App.new
      yield builder
      builder.build!
    end
  end

  class EventType
    def initialize(name, levels = [])
      @name = name
      @levels = levels
    end

    def level(level)
      @levels << level
    end

    def levels(levels)
      levels.each { |l| level l }
    end

    def build!(app)
      type = app.event_types.create(:name => @name, :title => @name, :external_id => @name)
      @levels.each do |level|
        type.levels.create(:name => level, :title => level, :external_id => level)
      end
    end
  end
end
