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

  # Returns a list of the top 100 bids and asks in the order book.
  # Ask orders are sorted by price ascending.
  # Bid orders are sorted by price descending.
  # Orders of the same price are aggregated.
  def orderbook_top(pair="XBTZAR")
    t = self.get('/api/1/orderbook_top', {pair: pair})
    usd_to_zar = Rails.cache.read("lucent:conversion_rate:usd:zar").to_f
    puts "\n\n ==== BitX::PublicApi ==== USD_to_ZAR: #{usd_to_zar} ==== \n\n"
    bids = []
    t['bids'].each do |o|
      bids << {
        # price: (BigDecimal(o['price'])/usd_to_zar).truncate(5),
        price: BigDecimal(o['price']),
        volume: BigDecimal(o['volume'])
      }
    end

    asks = []
    t['asks'].each do |o|
      asks << {
        # price: (BigDecimal(o['price'])/usd_to_zar).truncate(5),
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