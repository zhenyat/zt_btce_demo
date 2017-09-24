Rails.application.routes.draw do
  root 'pages#home'

  get 'pages/charts'
  get 'pages/depth_data'
  get 'pages/pairs'
  get 'pages/public_api'
  get 'pages/trade_api'
  get 'pages/trades_data'
  get 'trades/index'
  get 'trades/charts'
  get 'trades/ohlc'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
