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
  
  def charts
    @asks = []
    
    asks = Trade.where('kind == ? and pair_id = ?', 0, 1).order(:timestamp)#.first(100)
    asks.each do |ask|
#    Datum.create value: ask.price, closed_at: Time.at(ask.timestamp).strftime('%d-%m-%Y %H:%M:%S')
     tmp = [Time.at(ask.timestamp).strftime('%d-%m-%Y %H:%M:%S'), ask.price]
     tmp = [Time.at(ask.timestamp).strftime('%d-%m %H:%M'), ask.price]
     @asks << tmp
    end
#    @asks = Datum.first(20)
    puts @asks.count.to_s
  end
  
  def index
    add_trades
    @trades = Trade.all.order(tid: :desc)  
  end
  
  def ohlc
  
    #! WEX Candlestick Chart displays the local time
    timeframe = []
#    timeframe[0] = DateTime.parse("2017-09-24 11:00:00").to_i
#    timeframe[1] = DateTime.parse("2017-09-24 11:30:00").to_i

    timeframe[0] = time_round.to_i
    timeframe[1] = timeframe[0] +1800
    @timeframe = timeframe[0]

    trades = Trade.where('pair_id = ? and timestamp >= ? and timestamp < ?', 1, timeframe[0], timeframe[1]).order(:timestamp)

    @open   = trades.first
    @close  = trades.last
    @high   = trades.max_by(&:price)
    @low    = trades.min_by(&:price)
    @amount = trades.sum(:amount)
    
#    @open  = trades.first.price
#    @close = trades.first.last
#    @high  = trades.maximum(:price)
#    @low   = trades.minimum(:price)
    
  end
  
  def time_round(slot = 3.hour)
    Time.at((Time.now.to_i / slot).round * slot)
  end
  
  
  def round(granularity=1.hour)
    Time.at((self.to_time.to_i/granularity).round * granularity).to_datetime
  end

end