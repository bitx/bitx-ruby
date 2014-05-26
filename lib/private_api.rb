module PrivateApi

  #List Orders
  def list_orders(pair, opt={})
    conn = self.api_auth(opt)
    r = conn.get("/api/1/listorders?pair=#{pair}")
    raise self.Error.new("BitX listorders error: #{r.status}") unless r.status == 200

    j = JSON.parse(r.body)

    ol = []
    j['orders'].each do |bo|
      ol << {
        completed:    bo['state'] != 'PENDING',
        state:        bo['state'],
        created_at:   Time.at(bo['creation_timestamp'].to_i/1000),
        expires_at:   Time.at(bo['expiration_timestamp'].to_i/1000),
        order_id:     bo['order_id'],
        limit_price:  BigDecimal(bo['limit_price']),
        limit_volume: BigDecimal(bo['limit_volume']),
        base:         BigDecimal(bo['base']),
        fee_base:     BigDecimal(bo['fee_base']),
        counter:      BigDecimal(bo['counter']),
        fee_counter:  BigDecimal(bo['fee_counter']),
        type:   bo['type'].to_sym
      }
    end
    ol
  end

  #Post Order
  #order_type 'BID'/'ASK'
  ORDERTYPE_BID = 'BID'
  ORDERTYPE_ASK = 'ASK'
  def post_order(order_type, volume, price, pair, opt={})
    conn = self.api_auth(opt)
    r = conn.post('/api/1/postorder', {
      pair: pair,
      type: order_type,
      volume: volume.to_d.round(6).to_s,
      price: price.to_d.round(6).to_s
    })
    raise self.Error.new("BitX postorder error: #{r.status}") unless r.status == 200

    j = JSON.parse(r.body)
    raise self.Error.new("BitX postorder error: #{j['error']}") if j['error']
    j
  end

  #Stop Order
  def stop_order(order_id, opt={})
    conn = self.api_auth(opt)
    r = conn.post('/api/1/stoporder', {
      order_id: order_id
    })
    raise self.Error.new("BitX stoporder error: #{r.status}") unless r.status == 200
    true
  end

  #Balance
  def balance_for(asset='XBT', opt={})
    conn = self.api_auth(opt)
    r = conn.get('/api/1/balance?asset=' + asset)
    raise self.Error.new("BitX balance error: #{r.status}") unless r.status == 200
    j = JSON.parse(r.body)
    raise self.Error.new("BitX balance error: #{j['error']}") if j['error']
    balance = BigDecimal(j['balance'][0]['balance'])
    reserved = BigDecimal(j['balance'][0]['reserved'])
    {
      asset:      asset,
      balance:    balance,
      reserved:   reserved,
      available:  balance - reserved
    }
  end

  #Bitcoin Funding Address
  def funding_address(asset='XBT', opt={})
    conn = self.api_auth(opt)
    r = conn.get('/api/1/funding_address', {'asset' => asset})
    raise self.Error.new("BitX_funding address error: #{r.status}") unless r.status == 200
    JSON.parse(r.body)
  end

  def api_auth(opt={})
    api_key_id = opt[:api_key_id] || self.configuration.api_key_id
    api_key_secret = opt[:api_key_secret] || self.configuration.api_key_secret
    conn = self.conn
    conn.basic_auth(api_key_id, api_key_secret)
    conn
  end

end
