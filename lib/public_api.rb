module PublicApi

  def ticker(pair)
    t = self.get('/api/1/ticker', {pair: pair})
    {
      pair: pair,
      timestamp: Time.at(t["timestamp"].to_i/1000),
      ask: BigDecimal(t["ask"]),
      bid: BigDecimal(t["bid"]),
      last: BigDecimal(t["last_trade"]),
    }
  end

  def orderbook(pair)
    t = self.get('/api/1/orderbook', {pair: pair})

    bids = []
    t['bids'].each do |o|
      bids << {
        price: BigDecimal(o['price']),
        volume: BigDecimal(o['volume'])
      }
    end

    asks = []
    t['asks'].each do |o|
      asks << {
        price: BigDecimal(o['price']),
        volume: BigDecimal(o['volume'])
      }
    end

    return {timestamp: Time.at(trade['timestamp'].to_i/1000), bids: bids, asks: asks}
  end

  def trades(pair)
    t = self.get('/api/1/trades', {pair: pair})
    trades = []
    t['trades'].each do |trade|
      trades << {
        timestamp: Time.at(trade['timestamp'].to_i/1000),
        price: BigDecimal(trade['price']),
        volume: BigDecimal(trade['volume'])
      }
    end
    trades
  end

end