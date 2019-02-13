module Types
  class AppType < Types::BaseObject
    field :id, ID, :null => false
    field :name, String, :null => false

    field :event_types, [Types::EventTypeType], :null => false
  end
end
