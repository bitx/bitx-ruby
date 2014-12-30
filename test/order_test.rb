require "minitest/pride"
require "minitest/autorun"
require_relative "../lib/bitx.rb"

  module OrderStubs
    def self.conn
      stubs = Faraday::Adapter::Test::Stubs.new do |stub|

        stub.get('/api/1/listorders?pair=XBTZAR') {[ 200, {},
              '{
  "orders": [
    {
      "fee_counter": "0.00",
      "order_id": "BXMC2CJ7HNB88U4",
      "creation_timestamp": 1367849297609,
      "counter": "0.00",
      "limit_volume": "0.80",
      "limit_price": "1000.00",
      "state": "PENDING",
      "base": "0.00",
      "fee_base": "0.00",
      "type": "ASK",
      "expiration_timestamp": 1367935697609
    }
  ]
}']}


        stub.post('/api/1/postorder', {pair:'XBTZAR', type: 'BID', volume: '0.1', price: '1000.0'}) {[ 200, {},
              '{
  "order_id": "BXRANDOMORDERID23"
}']}



        stub.get('/api/1/orders/BXHW6PFRRXKFSB4') {[ 200, {},
              '{
  "order_id": "BXHW6PFRRXKFSB4",
  "creation_timestamp": 1402866878367,
  "expiration_timestamp": 0,
  "type": "ASK",
  "state": "PENDING",
  "limit_price": "6500.00",
  "limit_volume": "0.02",
  "base": "0.00",
  "counter": "0.00",
  "fee_base":"0.00",
  "fee_counter":"0.00"
}']}

        stub.post('/api/1/stoporder', {order_id: 'BXMC2CJ7HNB88U4'}) {[ 200, {},
              '{
  "success": true
}']}


      end

      Faraday.new do |faraday|
        faraday.adapter :test, stubs
      end
    end
  end

  class TestOrders < Minitest::Test

    def setup_module
      BitX.set_conn(OrderStubs.conn)
    end
    def setup_connection
      BitX::Connection.new(OrderStubs.conn)
    end

    def test_connection_list
      r = setup_connection.list_orders('XBTZAR')
      assert_equal r.size, 1
    end
    def test_list
      setup_module
      r = BitX.list_orders('XBTZAR')
      assert_equal r.size, 1
    end


    def test_connection_post_order
      r = setup_connection.post_order('BID', 0.1, 1000, 'XBTZAR')
      assert_equal r[:order_id], 'BXRANDOMORDERID23'
    end
    def test_post_order
      setup_module
      r = BitX.post_order('BID', 0.1, 1000, 'XBTZAR')
      assert_equal r[:order_id], 'BXRANDOMORDERID23'
    end

    def test_connection_get_order
      r = setup_connection.get_order('BXHW6PFRRXKFSB4')
      assert_equal r[:order_id], 'BXHW6PFRRXKFSB4'
    end
    def test_get_order
      setup_module
      r = BitX.get_order('BXHW6PFRRXKFSB4')
      assert_equal r[:order_id], 'BXHW6PFRRXKFSB4'
    end

    def test_connection_stop_order
      r = setup_connection.stop_order('BXMC2CJ7HNB88U4')
      assert_equal r[:success], true
    end
    def test_stop_order
      setup_module
      r = BitX.stop_order('BXMC2CJ7HNB88U4')
      assert_equal r[:success], true
    end


  end