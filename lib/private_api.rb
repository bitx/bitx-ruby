module PrivateApi

  class BitXError < StandardError
  end


  # <----- BALANCE .

  #Balance
  def balance_for(asset='XBT', opt={})
    # ---
    # - Deprecated
    # ---
    puts "BitX.balance_for will be deprecated. please use BitX.balance to get a list of account balances"
    opt.merge!({asset: asset})
    path = '/api/1/balance'
    j = authed_request(path, {params: opt})
    balance = BigDecimal(j[:balance][0][:balance])
    reserved = BigDecimal(j[:balance][0][:reserved])
    {
      asset:      asset,
      balance:    balance,
      reserved:   reserved,
      available:  balance - reserved
    }
  end

  def balance(opt={})
    path = '/api/1/balance'
    j = authed_request(path, opt)

    balances = []
    if j[:balance]
      j[:balance].each do |b|
        balance     = BigDecimal(b[:balance])
        reserved    = BigDecimal(b[:reserved])
         bal = {
          account_id:  b[:account_id],
          asset:       b[:asset],
          balance:     balance,
          reserved:    reserved,
          available:   balance - reserved,
          unconfirmed: BigDecimal(b[:unconfirmed])
        }
        bal[:name] = b[:name] if b[:name]
        balances << bal
      end
    end
    balances
  end

  # BALANCE -----/>

  # <----- ORDERS .

  #List Orders
  def list_orders(pair, opt={})
    #opt can include state: 'PENDING', pair: 'XBTZAR'
    opt.merge!({pair: pair})
    path = '/api/1/listorders'
    j = authed_request(path, {params: opt})

    ol = []
    if j[:orders]
      j[:orders].each do |bo|
        ol << format_order_hash(bo)
      end
    end
    ol
  end

  #Post Order
  #order_type 'BID'/'ASK'
  def post_order(order_type, volume, price, pair, opt={})
    params = {
      pair: pair,
      type: order_type,
      volume: volume.to_d.round(6).to_f.to_s,
      price: price.to_f.round.to_s
    }
    opt.merge!({params: params, method: :post})
    path = '/api/1/postorder'
    authed_request(path, opt)
  end

  #Stop Order
  def stop_order(order_id, opt={})
    options = {params: opt.merge!({order_id: order_id}), method: :post}
    path = '/api/1/stoporder'
    authed_request(path, options)
  end

  #Get Order
  def get_order(order_id, opt={})
    path = "/api/1/orders/#{order_id}"
    format_order_hash authed_request(path, {params: opt})
  end

  def format_order_hash(o)
    {
      completed:    o[:state] == 'COMPLETE',
      state:        o[:state],
      created_at:   Time.at(o[:creation_timestamp].to_i/1000),
      expires_at:   Time.at(o[:expiration_timestamp].to_i/1000),
      order_id:     o[:order_id],
      limit_price:  BigDecimal(o[:limit_price]),
      limit_volume: BigDecimal(o[:limit_volume]),
      base:         BigDecimal(o[:base]),
      fee_base:     BigDecimal(o[:fee_base]),
      counter:      BigDecimal(o[:counter]),
      fee_counter:  BigDecimal(o[:fee_counter]),
      type:         o[:type].to_sym,
      trades:       o[:trades]
    }
  end

  # ORDERS -----/>



  # <----- TRANSACTIONS .
  def transactions(account_id, min_row=1, max_row=100)
    path = "https://api.mybitx.com/api/1/accounts/#{account_id}/transactions"
    opt = {
      min_row: min_row,
      max_row: max_row
    }
    authed_request(path, opt)
  end

  def pending(account_id)
    authed_request("https://api.mybitx.com/api/1/accounts/#{account_id}/pending")
  end
  # TRANSACTIONS -----/>




  # <----- RECEIVE ADDRESSES .
  def new_receive_address(opt={})
    receive_address_request(opt, :post)
  end

  # if you have multiple XBT accounts you can specify an `address` option with the funding address
  def received_by_address(address=nil)
    if address.is_a? Hash
      address = address[:address]
    end
    receive_address_request({address: address}, :get)
  end

  #Bitcoin Funding Address
  def funding_address(asset='XBT', opt={})
    puts "BitX.funding_address will be deprecated. please use BitX.received_by_address with a specified address paramenter or an :address option to get details for that address"
    opt.merge!({asset: asset})
    receive_address_request(opt, :get)
  end

  def receive_address_request(opt, method)
    opt.merge!({asset: 'XBT'})
    path = '/api/1/funding_address'
    authed_request(path, {params: opt, method: method})
  end
  # RECEIVE ADDRESSES -----/>


  # <----- withdrawal requests .
  def withdrawals
    path = '/api/1/withdrawals'
    j = authed_request(path, {params: {}, method: :get})
    return j[:withdrawals] if j[:withdrawals]
    return j
  end

  def withdraw(type, amount)
    # valid types
    # ZAR_EFT,NAD_EFT,KES_MPESA,MYR_IBG,IDR_LLG

    path = '/api/1/withdrawals'
    authed_request(path, {params: {type: type, amount: amount}, method: :post})
  end

  def withdrawal(withdrawal_id)
    path = "/api/1/withdrawals/#{withdrawal_id}"
    authed_request(path, {params: {}, method: :get})
  end

  def cancel_withdrawal(withdrawal_id)
    path = "/api/1/withdrawals/#{withdrawal_id}"
    authed_request(path, {params: {}, method: :delete})
  end
  # withdrawal requests -----/>


  # <------- send .

  def send(amount, address, currency='XBT', description='', message='', pin=nil)
    # valid types
    # ZAR_EFT,NAD_EFT,KES_MPESA,MYR_IBG,IDR_LLG

    pin ||= self.configuration.api_key_pin rescue nil

    path = '/api/1/send'
    authed_request(path, {
      params: {
        amount: amount.to_s,
        address: address,
        currency: currency,
        description: description,
        message: message,
        pin: pin
      },
      method: :post
    })
  end

  # send ------/>


  # <------- quotes .

  def create_quote(pair, base_amount, type)
    #POST
    path = '/api/1/quotes'
    j = authed_request(path, {params: {type: type, pair: pair, base_amount: base_amount}, method: :post})
    extract_quote_from_body(j)
  end

  def exercise_quote(quote_id, pin=nil)
    #PUT
    pin ||= self.configuration.api_key_pin rescue nil
    path = "/api/1/quotes/#{quote_id}"
    j = authed_request(path, {
      params: {
        pin: pin
      },
      method: :put})
    extract_quote_from_body(j)
  end

  def discard_quote(quote_id)
    #DELETE
    path = "/api/1/quotes/#{quote_id}"
    j = authed_request(path, {method: :delete})
    extract_quote_from_body(j)
  end

  def view_quote(quote_id)
    #GET
    path = "/api/1/quotes/#{quote_id}"
    j = authed_request(path, {method: :get})
    extract_quote_from_body(j)
  end

  def extract_quote_from_body(quote)
    return nil unless quote
    quote[:created_at] = Time.at(quote[:created_at]/1000) if quote[:created_at]
    quote[:expires_at] = Time.at(quote[:expires_at]/1000) if quote[:expires_at]
    quote
  end

  # quotes ------/>



  def api_auth(opt={})
    api_key_id = opt[:api_key_id] || self.configuration.api_key_id
    api_key_secret = opt[:api_key_secret] || self.configuration.api_key_secret
    conn = self.conn
    conn.basic_auth(api_key_id, api_key_secret)
    conn
  end

  # opt can specify the method to be :post, :put, :delete
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
    when :put
      conn.put(path, opt[:params])
    when :delete
      conn.delete(path, opt[:params])
    else
      raise BitXError.new("Request must be :post or :get")
    end
    raise BitXError.new("BitX #{path} error: #{r.status}") unless r.status == 200

    t = begin
      JSON.parse(r.body, {symbolize_names: true})
    rescue
      {}
    end
    if t[:error]
      raise ::BitX::Error.new('BitX error: ' + t[:error])
    end
    t
  end

end
