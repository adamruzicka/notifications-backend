module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    def authorize(what, action, opts = {})
      Pundit.authorize(context[:current_user], what, action, opts)
    end

    def policy_scope(what)
      Pundit.policy_scope(context[:current_user], what)
    end

    field :allApps, [AppType], :null => false
    def all_apps
      policy_scope App
    end

    field :app, AppType, :null => true do
      argument :id, ID, :required => true
    end
    def app(id:)
      authorize App.find(id), :show?
    end

    field :allEndpoints, [EndpointType], :null => false
    def all_endpoints
      policy_scope Endpoint
    end

    field :endpoint, EndpointType, :null => true do
      argument :id, ID, :required => true
    end
    def endpoint(id:)
      authorize Endpoint.find(id), :show?, policy_class: EndpointPolicy
    end
  end
end
