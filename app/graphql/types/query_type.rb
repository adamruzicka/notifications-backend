module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    def authorize(what, action)
      Pundit.authorize(context[:current_user], what, action)
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
  end
end
