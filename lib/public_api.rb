module PublicApi

  def ticker(pair)
    t = self.get('/api/1/ticker', {pair: pair})
    {
      pair: pair,
      timestamp: Time.at(t['timestamp'].to_i/1000),
      ask: BigDecimal(t['ask']),
      bid: BigDecimal(t['bid']),
      last: BigDecimal(t['last_trade']),
      volume: t['rolling_24_hour_volume']
    }
  end

  def tickers
    tickers = []
    self.get('/api/1/tickers')['tickers'].each do |t|
      tickers << {
        pair: t['pair'],
        timestamp: Time.at(t['timestamp'].to_i/1000),
        ask: BigDecimal(t['ask']),
        bid: BigDecimal(t['bid']),
        last: BigDecimal(t['last_trade']),
        volume: t['rolling_24_hour_volume']
      }
    end
    tickers
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

    {bids: bids, asks: asks, timestamp: Time.at(t['timestamp'].to_i/1000)}
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

  def get(url, params=nil)
    r = self.conn.get(url, params)
    if r.status != 200
      raise ::BitX::Error.new("BitX error: #{r.status}")
    end
    t = JSON.parse r.body
    if t['error']
      raise ::BitX::Error.new('BitX error: ' + t['error'])
    end
    t
  end

end