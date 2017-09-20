class PagesController < ApplicationController
  
  def home
    t = ZtBtce::CliTest.new
    t.say_hello
    
    @domain = ZtBtce::DOMAIN
    @key    = ZtBtce::KEY
    
    asterisks =''
    for i in (0..59)
      asterisks[i]= '*'
    end
    @secret = "#{asterisks}#{ZtBtce::SECRET[-4..-1]}"
  end

  # Public API methods demonstration 
  def public_api
   pairs = %w(btc_usd btc_eur btc_rur).join('-')
    @info   = ZtBtce.info
    @ticker = ZtBtce.ticker #pairs: "pairs
    @depth  = ZtBtce.depth  pairs: pairs, limit: 20
    @trades = ZtBtce.trades pairs: pairs, limit: 10
  end

  def trade_api
    if session['HTTP_REFERER'].nil?
      puts "ZT! session['HTTP_REFERER'] =  nil"
    else
      puts "ZT! #{session['HTTP_REFERER']}"
    end
    @account_info  = ZtBtce.account_info
    @active_orders = ZtBtce.active_orders 'mode' => 'emulator'
    @order_info    = ZtBtce.order_info 343152, 'mode' => 'emulator'
  end
end
