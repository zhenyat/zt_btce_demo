class TradesController < ApplicationController
  
  # Adds news data from the stock to DB
  def add_trades
    t_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
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
    t_finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts "===== Trades added: #{add_count} | Trades skipped: #{skip_count} at #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}. Time elapsed: #{(t_finish - t_start).round(2)} sec."
  end
  
  def candlesticks
    pair    = 'btc_usd'
    pair_id = Pair.find_by(name: pair).id
    
    period = 2.day        # Data for last 24 hours period
    
    trades = Trade.where('pair_id = ?', pair_id).order(:timestamp)      # All data
#    trades = Trade.where('pair_id = ? AND timestamp >= ?', pair_id, (Time.now - period).to_i).order(:timestamp)
    
    candles    = []         # Array of the result
    time_slot  = 30.minute
    time_frame = []

#   time_frame[0] = (set_time_frame trades.first.timestamp, time_slot)   # All data 
    time_frame[0] = (set_time_frame (Time.now - period), time_slot)
    time_frame[1] = (time_frame[0] + time_slot)
 
    t_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    while time_frame.first <= Time.now.to_i
      
      candle_trades = trades.where('timestamp >= ? and timestamp < ?', time_frame.first, time_frame.last).order(:timestamp)

      if candle_trades.present?
        data = []
        price_min   = candle_trades.minimum(:price).to_f                 # BigDecimal to Float - MUST BE DONE!
        price_max   = candle_trades.maximum(:price).to_f
        price_first = candle_trades.first.price.to_f
        price_last  = candle_trades.last.price.to_f
        
        data << Time.at(time_frame.first).strftime('%d-%M-%Y %H:%M')
        data << price_min
        data << price_first
        data << price_last
        data << price_max
        data << (price_max + price_min + price_last) / 3
        candles << data
      end

      time_frame[0] += time_slot
      time_frame[1] += time_slot
    end
    t_finish = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    puts "===== Time elapsed: #{(t_finish - t_start).round(2)} sec"
    gon.pair    = pair
    gon.candles = candles
  end
      
  def index
    add_trades
    puts "***** ZT! Sleep 5 sec"
    sleep 5
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

  def update_candles_array pair_id=1, period=1.day
    
    filename = Rails.root.join "db/data_#{pair_id}"
    if filename.exist?
      file = File.open filename, 'a+'
    else
      file   = File.open filename, 'w'
      trades = Trade.where('pair_id = ? AND timestamp >= ?', pair_id, (Time.now - period).to_i).order(:timestamp)
      trades.each do |t|
        a = []
        a << t.id << t.kind << t.price << t.amount << t.tid << t.timestamp
        file.write a.to_json
      end
#      a << t.id << t.kind << t.price << t.amount << t.tid << t.timestamp
    end
  end
  
end

=begin
file   = File.open filename, 'w'
tr = trades.where('timestamp >= ?', (Time.now - 1.day).to_i)
tr.each do |t|
  a = []
  a << t.id << t.kind << t.price << t.amount << t.tid << t.timestamp
  file.puts a.to_json
end
file.close

file   = File.open filename, 'r'
b=[]
lines = file.readlines
file.close
lines.each do |line|
  arr = JSON.parse(line)
  b << arr  if arr.last >= (Time.now - 1.day).to_i
end
=end