require 'sweettooth'
require 'test/unit'
require 'mocha/setup'
require 'stringio'
require 'shoulda'

#monkeypatch request methods
module SweetTooth
  @mock_rest_client = nil

  def self.mock_rest_client=(mock_client)
    @mock_rest_client = mock_client
  end

  def self.execute_request(opts)
    get_params = (opts[:headers] || {})[:params]
    post_params = opts[:payload]
    case opts[:method]
    when :get then @mock_rest_client.get opts[:url], get_params, post_params
    when :post then @mock_rest_client.post opts[:url], get_params, post_params
    when :delete then @mock_rest_client.delete opts[:url], get_params, post_params
    end
  end
end

def test_response(body, code=200)
  # When an exception is raised, restclient clobbers method_missing.  Hence we
  # can't just use the stubs interface.
  body = MultiJson.dump(body) if !(body.kind_of? String)
  m = mock
  m.instance_variable_set('@sweettooth_values', { :body => body, :code => code })
  def m.body; @sweettooth_values[:body]; end
  def m.code; @sweettooth_values[:code]; end
  m
end

def test_customer(params={})
  {
    :_object => "customer",
    :id => "cus_test_customer",
    :account_id => "acc_test_account",
    :first_name => "Wayne",
    :last_name => "Rooney",
    :email => "wrooney@example.com",
    :date_of_birth => "1985-10-24",
    :points_balance => 1200,
    :created => "2014-01-14T17:25:32.000Z",
    :updated => "2014-01-14T17:25:32.000Z"
  }.merge(params)
end

def test_customer_array
  {
    :items => [test_customer, test_customer, test_customer],
    :_object => 'collection',
    :url => '/v1/customers'
  }
end

def test_activity(params={})
  {
    :_object => "activity",
    :id => "act_test_activity",
    :account_id => "acc_test_account",
    :channel_id => "cha_test_channel",
    :customer_id => "cus_test_customer",
    :verb => "signup",
    :object => {},
    :processed => nil,
    :created => "2014-01-14T19:25:32.000Z",
    :updated => "2014-01-14T19:25:32.000Z"
  }.merge(params)
end

def test_redemption(params={})
  {
    :_object => "redemption",
    :id => "red_test_redemption",
    :customer_id => "cus_test_customer",
    :channel_id => "cha_test_channel",
    :redemption_option_id => "rop_test_redemption_option",
    :status => "completed",
    :comment => nil,
    :created => "2014-01-14T19:25:32.000Z",
    :updated => "2014-01-14T19:25:32.000Z"
  }.merge(params)
end

def test_spending(params={})
  {
    :_object => "spending",
    :id => "spe_test_spending",
    :customer_id => "cus_test_customer",
    :spending_option_id => "spo_test_spending_option",
    :status => "completed",
    :comment => nil,
    :created => "2014-01-14T19:25:32.000Z",
    :updated => "2014-01-14T19:25:32.000Z"
  }.merge(params)
end

def test_spending_option(params={})
  {
    :_object => "spending_option",
    :id => "spo_test_spending_option",
    :readable_id => "gift_item",
    :name => "Gift Item",
    :description => "Spend 100 points to receive an exclusive gift package",
    :created => "2014-01-14T17:25:32.000Z",
    :updated => "2014-01-14T17:25:32.000Z"
  }.merge(params)
end

def test_redemption_option(params={})
  {
    :_object => "redemption_option",
    :id => "rop_test_redemption_option",
    :account_id => "acc_test_account",
    :name => "Free Shipping",
    :description => "Spend 100 points to receive free shipping",
    :created => "2014-01-14T17:25:32.000Z",
    :updated => "2014-01-14T17:25:32.000Z"
  }.merge(params)
end

def test_redemption_option_array
  {
    :items => [test_redemption_option, test_redemption_option, test_redemption_option],
    :_object => 'collection',
    :url => '/v1/redemption_options'
  }
end

def test_spending_option_array
  {
    :items => [test_spending_option, test_spending_option, test_spending_option],
    :_object => 'collection',
    :url => '/v1/spending_options'
  }
end

def test_invalid_api_key_error
  {
    "error" => {
      "type" => "invalid_request_error",
      "message" => "Invalid API Key provided: invalid"
    }
  }
end

def test_invalid_exp_year_error
  {
    "error" => {
      "code" => "invalid_expiry_year",
      "param" => "exp_year",
      "type" => "card_error",
      "message" => "Your card's expiration year is invalid"
    }
  }
end

def test_missing_id_error
  {
    :error => {
      :param => "id",
      :type => "invalid_request_error",
      :message => "Missing id"
    }
  }
end

def test_api_error
  {
    :error => {
      :type => "api_error"
    }
  }
end

def test_delete_discount_response
  {
    :deleted => true,
    :id => "di_test_coupon"
  }
end

class Test::Unit::TestCase
  include Mocha

  setup do
    @mock = mock
    SweetTooth.mock_rest_client = @mock
    SweetTooth.api_key="sk_test_q6p2uvfgQzgposDZ4n1qJdUM"
  end

  teardown do
    SweetTooth.mock_rest_client = nil
    SweetTooth.api_key=nil
  end
end

