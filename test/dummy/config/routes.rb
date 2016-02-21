Rails.application.routes.draw do

  # JSONAPI routes
  scope '/api/v1' do # Optional scoping

    [ # List of your API controllers
      :articles, :authors, :header_images, :tags
    ].each do |resources_name|
      resources resources_name do
        controller resources_name do
          get     'relationships/:relationship', action: "relationship_show"
          patch   'relationships/:relationship', action: "relationship_update"
          post    'relationships/:relationship', action: "relationship_add"
          delete  'relationships/:relationship', action: "relationship_remove"
        end
      end
    end

  end

end
