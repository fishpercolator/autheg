Rails.application.routes.draw do

  scope :api, defaults: {format: :json} do
    resources :examples
  end

end
