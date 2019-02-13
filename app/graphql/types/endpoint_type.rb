module Types
  class EndpointType < Types::BaseObject
    field :id, ID, :null => false
    field :name, String, :null => false
    field :url, String, :null => false
    field :type, String, :null => false # TODO: enum?
    field :active, Boolean, :null => false
    field :filters, [FilterType], :null => false
  end
end
