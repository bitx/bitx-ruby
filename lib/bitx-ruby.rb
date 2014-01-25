require 'faraday'
require 'json'
require 'bigdecimal'

class BitX

  class Error < StandardError
  end

  def ticker(pair)
    r = conn.get('/api/1/ticker', {pair: pair})
    if r.status != 200
      raise Error('BitX error: #{r.status}')
    end
    t = JSON.parse r.body
    {
      pair: pair,
      timestamp: Time.at(t["timestamp"].to_i/1000),
      ask: BigDecimal(t["ask"]),
      bid: BigDecimal(t["bid"]),
      last: BigDecimal(t["last_trade"]),
    }
  end

private

  def conn
    conn = Faraday.new(url: 'https://bitx.co.za')
    conn.headers[:user_agent] = "bitx-ruby/0.0.1"
    conn
  end
end
