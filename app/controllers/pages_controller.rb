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
#    t = ZtBtce::CliTest.new
#    t.say_hello
    
    @domain = ZtBtce::DOMAIN
    @key    = ZtBtce::KEY
    
    asterisks =''
    for i in (0..59)
      asterisks[i]= '*'
    end
    @secret = "#{asterisks}#{ZtBtce::SECRET[-4..-1]}"
  end
    
  # Splits all orders by type (ask / bid and puts them in Hash by pair)
  def depth_split depth
    asks = {}
    bids = {}
    
    depth.each do |pair|   # pair is an Array of 2 elements: [string (pair name), hash]
      pair_name   = pair.first
      asks_orders = []
      bids_orders = []
      asks_total  = 0
      bids_total  = 0
      
      pair.last['asks'].each do |ask|  # Get all *asks* and collect them in the Array
        asks_orders << ask
        asks_total += ask.last
      end

      # Fill a Hash
      asks.update("#{pair_name}" => {orders: asks_orders, total: asks_total})
      
      pair.last['bids'].each do |bid|  # Get all *bids* and collect them in the Array
        bids_orders << bid
        bids_total += (bid.first * bid.last)
      end
      # Fill a Hash
      bids.update("#{pair_name}" => {orders: bids_orders, total: bids_total})
    end

    return asks, bids
  end

  # Detailed *depth* handling
  def in_depth
    pairs = %w(btc_usd eth_usd ltc_usd).join('-')
#    pairs = 'btc_usd'
    limit = 5000
    
    depth = ZtBtce.depth pairs: pairs, limit: limit
    
    @asks, @bids = depth_split depth
  end

  # Public API methods demonstration 
  def public_api
    pairs = %w(btc_usd eth_usd ltc_usd).join('-')
    @info   = ZtBtce.info
    @ticker = ZtBtce.ticker pairs: pairs
    @depth  = ZtBtce.depth  pairs: pairs, limit: 20
    @trades = ZtBtce.trades pairs: pairs, limit: 20
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
