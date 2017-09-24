module TradesPro
  extend ActiveSupport::Concern
  
  # Select trades by pair and separates the selection on asks & bids 
  def trades_by_pair pair_name
    pair_id   = Pair.find_by(name: pair_name).id
    trades    = Trade.where('pair_id = ?', pair_id).order(:timestamp)
    
    asks = trades.where('kind = ?', 0)
    bids = trades.where('kind = ?', 1)
    
    return asks, bids
  end
end