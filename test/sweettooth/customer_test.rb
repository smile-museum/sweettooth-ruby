require File.expand_path('../../test_helper', __FILE__)

module SweetTooth
  class CustomerTest < Test::Unit::TestCase
    should "customers should be listable" do
      @mock.expects(:get).once.returns(test_response(test_customer_array))
      c = SweetTooth::Customer.all.items
      assert c.kind_of? Array
      assert c[0].kind_of? SweetTooth::Customer
    end

    should "customers should be deletable" do
      @mock.expects(:delete).once.returns(test_response(test_customer({:deleted => true})))
      c = SweetTooth::Customer.new("test_customer")
      c.delete
      assert c.deleted
    end

    should "customers should be updateable" do
      @mock.expects(:get).once.returns(test_response(test_customer({:email => "lmessi@example.com"})))
      @mock.expects(:post).once.returns(test_response(test_customer({:email => "cronaldo@example.com"})))
      c = SweetTooth::Customer.new("test_customer").refresh
      assert_equal c.email, "lmessi@example.com"
      c.email = "cronaldo@example.com"
      c.save
      assert_equal c.email, "cronaldo@example.com"
    end

    should "create should return a new customer" do
      @mock.expects(:post).once.returns(test_response(test_customer))
      c = SweetTooth::Customer.create
      assert_equal "cus_test_customer", c.id
    end

  end
end
