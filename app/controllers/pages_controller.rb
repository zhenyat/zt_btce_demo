class PagesController < ApplicationController

    def charts
      pairs = 'btc_usd'
      @trades = ZtBtce.trades pairs: pairs, limit: 5000

      asks = []
      bids = []
      key  = 1
      @a_amnt = {}
      @b_amnt = {}
      @trades[pairs].each do |a|
        if a['type'] == 'ask'
          asks << a
          @a_amnt[Time.at(a['timestamp'])] = a['amount']
        else
          bids << a
          @b_amnt[Time.at(a['timestamp'])] = a['amount']
        end
        key += 1
      end
      @counts = { asks: asks.count, bids: bids.count}


      
      
    end

    
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
   pairs = %w(btc_usd eth_usd ltc_usd).join('-')
   pairs = 'btc_usd'
#    @info   = ZtBtce.info
    @ticker = ZtBtce.ticker pairs: pairs
    @depth  = ZtBtce.depth  pairs: pairs, limit: 25
#    @trades = ZtBtce.trades pairs: pairs, limit: 20
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
