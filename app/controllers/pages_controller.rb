class PagesController < ApplicationController

  include TradesPro
  
  def charts
    pair = 'btc_usd'
    
    @asks, @bids = trades_by_pair pair

    puts @asks.count
    puts @bids.count
 
    @data = []
    @asks.map do |value|
      @data << [Time.at(value.timestamp).strftime('%d-%m %H:%M'), value.price]

    end
      puts @data.last
    
#    @a_amnt = {}
#    @b_amnt = {}
#    @trades[pairs].each do |a|
#      if a['type'] == 'ask'
#        asks << a
#        @a_amnt[Time.at(a['timestamp'])] = a['amount']
#      else
#        bids << a
#        @b_amnt[Time.at(a['timestamp'])] = a['amount']
#      end
#      key += 1
#    end
#    @counts = { asks: asks.count, bids: bids.count}
  end

  # Detailed *depth* handling
  def depth_data
    pairs = %w(btc_usd eth_usd ltc_usd).join('-')
#    pairs = 'btc_usd'
    limit = 5000
    
    depth = ZtBtce.depth pairs: pairs, limit: limit
    
    @asks, @bids = depth_split depth

    @asks_stat = depth_stat @asks
    @bids_stat = depth_stat @bids
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
  
  ##############################################################################
  # Calculates statistical values
  #     Min / Max / Average of Orders Prices
  #
  #     stat = { pair_name: {price_min, price_max, price_avg, total_orders, total_amounts[]} }
  ##############################################################################
  def depth_stat orders
    stat = {}
    
    orders.each do |pair|
      prices       = []
      pair_amounts = [0, 0]

      pair_name  = pair.first  
      pair.last[:orders].each do |order|
        prices << order[0]
        pair_amounts[0] += order[1]              # btc
        pair_amounts[1] += order[0] * order[1]   # usd
      end

      stat.update("#{pair_name}" => {
          price_min:    prices.min,
          price_max:    prices.max,
          price_sum:    prices.sum,
          orders:       prices.size,
          pair_amounts: pair_amounts
      })
    end
    stat
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

  def pairs
    @pairs = Pair.all
  end
  
  # Public API methods demonstration 
  def public_api
    pairs = %w(btc_usd eth_usd ltc_usd).join('-')
    @info   = ZtBtce.info
    @ticker = ZtBtce.ticker pairs: pairs
    @depth  = ZtBtce.depth  pairs: pairs, limit: 20
    @trades = ZtBtce.trades pairs: pairs, limit: 30
    puts @trades
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
  
  def trades_data
    pairs = %w(btc_usd eth_usd ltc_usd).join('-')
#    pairs = 'btc_usd'
    limit = 5000
    
    @trades = ZtBtce.trades pairs: pairs, limit: limit

    
#    @asks, @bids = trades_split @trades
    
  end
  
  # Splits trades by a sell / buy type
  def trades_split trades
    asks = {}
    bids = {}

    trades.each do |pair_trades|
      ask_orders = []
      bid_orders = []
      
      pair_name = pair_trades.first
      pair_trades.last.each do |trade|
        if trade['type'] == 'ask'   # Separate asks from bids
          ask_orders << trade
        else
          bid_orders << trade
        end
      end  
      asks.update({"#{pair_name}" => ask_orders})
      bids.update({"#{pair_name}" => bid_orders})
    end
    
    return asks, bids
  end
  
  def trades_store trades
  
  end
end
