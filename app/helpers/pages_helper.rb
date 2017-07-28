module PagesHelper
  
  def date_from_timestamp timestamp
    Time.at(timestamp).strftime('%d-%m-%Y %H:%M:%S')
  end
  
  def order_status status
    case status
    when 0
      "Active"
    when 1
      "Executed"
    when 2
      "Canceled"
    when 3
      "Canceled / Executed partly"
    end
  end
  ##############################################################################
  #   Splits *trades* hash into two ones by type
  #
  #   25.07.2017  ZT
  ##############################################################################
  def split_trades_by_type(trades)
    ask_trades = {}
    bid_trades = {}

    trades.each do |pair_trades|
      asks = []
      bids = []   
      pair_name = pair_trades.first
      pair_trades.last.each do |trade|
        if trade['type'] == 'ask'   # Separate asks from bids
          asks << trade
        else
          bids << trade
        end
      end  
      ask_trades.update({"#{pair_name}" => asks})
      bid_trades.update({"#{pair_name}" => bids})
    end
    
    return ask_trades, bid_trades
  end
end
