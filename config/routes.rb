Byp::Application.routes.draw do
  resources :news_items do
    member do
      get 'feature'
    end
  end

  get "pages/index"

  get "pages/faq"

  resources :specialties do
    collection do
      post 'search'
    end
  end

  resources :user_sessions

  resources :users do
    member do
      get 'invite'
      get 'orphan'
      get 'adopt'
      get 'trust_links'
      get 'sever_trust'
      get 'trust'
    end
    
    collection do
      get 'orphanage'
    end
  end
  
  resources :sponsorship_offers do
    member do
      post 'accept'
      post 'reject'
    end
  end
  
  resources :password_resets
  
  match 'register/:activation_code', :to => 'users#activate', :as => 'register'

  match 'login', :to => 'user_sessions#new'
  match 'logout', :to => 'user_sessions#destroy'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"
  
  root :to => 'pages#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
