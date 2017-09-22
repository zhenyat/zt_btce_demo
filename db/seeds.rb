# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if Pair.count == 0
  info = ZtBtce.info

  if info.present?
    info['pairs'].each do |pair|
      values = pair.last

      Pair.create name:       pair.first,           decimal_places: values['decimal_places'],
                  max_price:  values['max_price'],  min_price:      values['min_price'],
                  min_amount: values['min_amount'], hidden:         values['hidden'],
                  fee:        values['fee']
    end
  end
end

if Trade.count == 0
  
  pairs = %w(btc_usd eth_usd ltc_usd).join('-')
  limit = 5000
    
  trades = ZtBtce.trades pairs: pairs, limit: limit
  
  count = 0
  if trades.present?
    trades.each do |trade|
      pair_name =trade.first
      pair_id   = Pair.find_by(name: pair_name).id
      deals     = trade.last
      
      deals.each do |deal|
        kind = (deal['type'] == 'ask') ? 0 : 1
        Trade.create! pair_id: pair_id,        kind: kind,        price:     deal['price'],
                     amount:   deal['amount'], tid:  deal['tid'], timestamp: deal['timestamp']
        count += 1
      end
    end
  end
  puts "Trades created: #{count}"
end
