module Types
  class FilterType < Types::BaseObject
    field :id, ID, :null => false
    field :endpoints, [EndpointType], :null => false
    field :apps, [AppType], :null => false
    field :severities, [String], :null => false
  end
end
