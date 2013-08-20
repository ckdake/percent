Percent::Application.routes.draw do
  match "/auth/:provider/callback" => "sessions#create", via: :all
  match "/auth/failure" => "sessions#signin_failed", via: :all
  delete "/signout" => "sessions#delete", as: :signout
  get "/signin" => redirect("/auth/stable")

  resource :dashboard, only: [:show]

  root to: "dashboards#show"
end
