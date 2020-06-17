Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'person#new'

  get '/home' => 'home#index'

  get "user/index"
  get "user/edit"
  get "user/new"
  post "user/edit"
  get "user/delete"

  get "user/change_password"
  post "user/change_password"

  post "user/new"
  get "user/view"
  get "/logout" => 'user#logout'
  get "/login" => "user#login"
  post "/login" => "user#login"

  get "user/roles"
  get "user/permissions"

  get "user/new_role"
  get "user/edit_role"
  get "user/edit_role"
  post "user/edit_role"
  post "user/new_role"
  get "user/delete_role"
  get "user/view_role"

  get "user/new_permission"
  get "user/edit_permission"
  get "user/edit_permission"
  post "user/edit_permission"
  post "user/new_permission"
  get "user/delete_permission"
  get "user/view_permission"
  get "person/suggest"

  get "user/role_permissions"
  post "user/role_permissions"

  get "user/user_roles"
  post "user/user_roles"

  get "location/index"
  get "location/tags"

  get "location/new_tag"
  post "location/new_tag"

  get '/person/get_ta_complete'
  get '/person/get_village_complete'
  get '/person/get_hospital_complete'

  get "location/view_tag"
  get  "location/edit_tag"
  post "location/edit_tag"
  get "location/delete_tag"

  get "location/new"
  post "location/new"
  get "location/view"
  get "location/delete"

  get  "location/edit"
  post "location/edit"
  get "location/set_current"

  get "/location/health_facilities"

  get "location/ajax_locations"
  get "person/person_types"
  get "person/new_type"
  post "person/new_type"

  get "person/edit_type"
  post "person/edit_type"

  get "person/view_type"
  get "person/delete_type"

  get "person/index"
  get "person/ajax_persons"

  get "person/new"
  post "person/new"

  get "person/delete_all_records"

  get "/edit/:person_id"  => "person#edit"
  post "/edit/:person_id"  => "person#edit"

  get "person/view"
  get "module/view_module"

  get "client/client_suggestions"

  get "/complaints/:client_id" => "encounter#complaints"
  post "/create/:client_id" => "encounter#create"

  get "/diagnosis/:client_id" => "encounter#diagnosis"
  get "/vitals/:client_id" => "encounter#vitals"
  get "/prescribe/:client_id" => "drug#prescribe"
  get "/dispense/:client_id" => "drug#dispense"
  get "/outcomes/:client_id"  => "encounter#outcomes"

  get "/countries" => "location#countries"
  get "/districts" => "location#districts"
  get "/tas" => "location#tas"
  get "/villages" => "location#villages"
  get '/show_person/:person_id' => 'person#show'
  post "/save_record" => "person#save_record"
  get  "/dump_data" => "person#dump_data"
  get  "/offload_rollback" => "person#offload_rollback"
  post "/dump_data" => "person#dump_data"

  get "/report/download_all"

end
