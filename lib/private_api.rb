module PrivateApi

  class BitXError < StandardError
  end

  #List Orders
  def list_orders(pair, opt={})
    opt.merge!({pair: pair})
    path = '/api/1/listorders'
    r = authed_request(path, {params: opt})
    j = JSON.parse(r.body)

    ol = []
    if j['orders']
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
    end
    ol
  end

  #Post Order
  #order_type 'BID'/'ASK'
  ORDERTYPE_BID = 'BID'
  ORDERTYPE_ASK = 'ASK'
  def post_order(order_type, volume, price, pair, opt={})
    params = {
      pair: pair,
      type: order_type,
      volume: volume.to_d.round(6),
      price: price.to_d.round(6)
    }
    opt.merge!({params: params, method: :post})
    path = '/api/1/postorder'
    r = authed_request(path, opt)
    j = JSON.parse(r.body)
    raise BitXError.new("BitX postorder error: #{j['error']}") if j['error']
    j
  end

  #Stop Order
  def stop_order(order_id, opt={})
    options = {params: opt.merge!({order_id: order_id}), method: :post}
    path = '/api/1/stoporder'
    r = authed_request(path, options)
    true
  end

  #Balance
  def balance_for(asset='XBT', opt={})
    opt.merge!({asset: asset})
    path = '/api/1/balance'
    r = authed_request(path, {params: opt})
    j = JSON.parse(r.body)
    raise BitXError.new("BitX balance error: #{j['error']}") if j['error']
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
    opt.merge!({asset: asset})
    path = '/api/1/funding_address'
    r = authed_request(path, {params: opt})
    JSON.parse(r.body)
  end

  def api_auth(opt={})
    api_key_id = opt[:api_key_id] || self.configuration.api_key_id
    api_key_secret = opt[:api_key_secret] || self.configuration.api_key_secret
    conn = self.conn
    conn.basic_auth(api_key_id, api_key_secret)
    conn
  end

  # opt can specify the method to be :post
  # opt can specify request params in :params
  # opt could also include the api_key_id and api_key_secret
  def authed_request(path, opt={})
    method = opt[:method] || :get
    conn = self.api_auth(opt)
    r = case method
    when :get
      conn.get(path, opt[:params])
    when :post
      conn.post(path, opt[:params])
    else
      raise BitXError.new("Request must be :post or :get")
    end
    raise BitXError.new("BitX #{path} error: #{r.status}") unless r.status == 200
    r
  end

end
