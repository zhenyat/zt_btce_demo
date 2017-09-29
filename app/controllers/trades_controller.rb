class TradesController < ApplicationController
  
  # Adds news data from the stock to DB
  def add_trades
    add_count  = 0
    skip_count = 0  
    max_tid    = Trade.all.maximum(:tid)
    
    # FYI! finds record with max value:  Trade.all.max_by(&:tid)
   
    pairs = %w(btc_usd eth_usd ltc_usd).join('-')
#    pairs = "btc_usd"
    limit = 5000
    
    trades = ZtBtce.trades pairs: pairs, limit: limit
    
    trades.each do |trade|
      pair_name =trade.first
      pair_id   = Pair.find_by(name: pair_name).id
      deals     = trade.last
#      deals.reverse!
      deals.each do |deal|
        if deal['tid'] > max_tid

          kind = (deal['type'] == 'ask') ? 0 : 1
          Trade.create! pair_id: pair_id,        kind: kind,        price:     deal['price'],
                       amount:   deal['amount'], tid:  deal['tid'], timestamp: deal['timestamp']
          add_count += 1
        else
          skip_count += 1
        end
      end
    end
    puts "===== Trades added: #{add_count} | Trades skipped: #{skip_count} at #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  end
  
  def candlesticks
    pair    = 'btc_usd'
    pair_id = Pair.find_by(name: pair).id
    
    trades = Trade.where('pair_id = ?', pair_id).order(:timestamp)
    
    candles    = []         # Array of the result
    time_slot  = 30.minute
    time_frame = []

#   time_frame[0] = (set_time_frame trades.first.timestamp, time_slot)   # All data 
    time_frame[0] = (set_time_frame (Time.now - 1.day), time_slot)       # Data for last 24 hours
    time_frame[1] = (time_frame[0] + time_slot)
 
     while time_frame.first <= Time.now.to_i
      
      candle_trades = trades.where('timestamp >= ? and timestamp < ?', time_frame.first, time_frame.last).order(:timestamp)

      if candle_trades.present?
        data = []
        data << Time.at(time_frame.first).strftime('%d-%M-%Y %H:%M')
        data << candle_trades.minimum(:price).to_f                 # BigDecimal to Float - MUST BE DONE!
        data << candle_trades.first.price.to_f
        data << candle_trades.last.price.to_f
        data << candle_trades.maximum(:price).to_f
        candles << data
      end

      time_frame[0] += time_slot
      time_frame[1] += time_slot
    end
    
    gon.pair    = pair
    gon.candles = candles
  end
      
  def index
    add_trades
    @trades = Trade.all.order(tid: :desc)  
  end
  
  def ohlc
    #! WEX Candlestick Chart displays the local time

#    add_trades

    @counts  = []
    @amounts = []
    @amounts_bar = []
    
    pair    = 'btc_usd'
    @pair_id = Pair.find_by(name: pair).id
    
    trades = Trade.where('pair_id = ?', @pair_id).order(:timestamp)
    
    @candles   = {}         # Hash of the result
    time_slot  = 30.minute
    time_frame = []

   #time_frame[0] = (set_time_frame trades.first.timestamp, time_slot)   # All data 
    time_frame[0] = (set_time_frame (Time.now - 1.day), time_slot)        # Data for last 24 hours
    time_frame[1] = (time_frame[0] + time_slot)
    
    while time_frame.first <= Time.now.to_i
      
      candle_trades = trades.where('timestamp >= ? and timestamp < ?', time_frame.first, time_frame.last).order(:timestamp)

      if candle_trades.present?
        data = []
        data << candle_trades.minimum(:price)
        data << candle_trades.first.price
        data << candle_trades.last.price
        data << candle_trades.maximum(:price)
        data << candle_trades.sum(:amount)
        data << candle_trades.count
        data << time_slot

        @candles[time_frame.first] = data

#        @counts << [Time.at(time_frame.first).strftime('%d-%m-%Y %H:%M:%S'), candle_trades.sum(:amount)]
#         @counts << [time_frame.first+3.hour, candle_trades.sum(:amount)]
         @counts  << [time_frame.first+3.hour, candle_trades.count]
         @amounts << [time_frame.first, candle_trades.sum(:amount)]
         @amounts_bar << [Time.at(time_frame.first).strftime('%d %H:%M'), candle_trades.sum(:amount)]
        
      end
      
      time_frame[0] += time_slot
      time_frame[1]  += time_slot
    end    
  end
  
  def time_round(slot = 3.hour)
    Time.at((Time.now.to_i / slot).round * slot)
  end
  
  # Sets the nearest timeframe 
  def set_time_frame time, time_slot = 30.minutes
    Time.at(((time.to_i / time_slot).round *  time_slot) + time_slot).to_i
  end
end