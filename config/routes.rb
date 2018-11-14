Rails.application.routes.draw do
  get 'home/index'
  get 'confirm', to: 'home#confirm'
  get 'result', to: 'home#result'
  post 'vote', to: 'home#vote'
  root 'home#index'

  # Uncomment for testing only
  # get 'vote', to: 'home#confirm'
end
