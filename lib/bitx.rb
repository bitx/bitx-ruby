require 'faraday'
require 'json'
require 'bigdecimal'

class BitX

  class Error < StandardError
  end

  def ticker(pair)
    t = get('/api/1/ticker', {pair: pair})
    {
      pair: pair,
      timestamp: Time.at(t["timestamp"].to_i/1000),
      ask: BigDecimal(t["ask"]),
      bid: BigDecimal(t["bid"]),
      last: BigDecimal(t["last_trade"]),
    }
  end

  def orderbook(pair)
    t = get('/api/1/orderbook', {pair: pair})

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

    return {bids: bids, asks: asks}
  end

  def trades(pair)
    t = get('/api/1/trades', {pair: pair})
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

private

  def conn
    conn = Faraday.new(url: 'https://bitx.co.za')
    conn.headers[:user_agent] = "bitx-ruby/0.0.1"
    conn
  end

  def get(url, params)
    r = conn.get(url, params)
    if r.status != 200
      raise BitX::Error.new("BitX error: #{r.status}")
    end
    t = JSON.parse r.body
    if t['error']
      raise BitX::Error.new('BitX error: ' + t['error'])
    end
    t
  end
end
