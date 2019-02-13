module Types
  class EventTypeType < Types::BaseObject
    field :id, ID, :null => false
    field :name, String, :null => false

    field :app, AppType, :null => false
  end
end
