require File.expand_path('../../test_helper', __FILE__)

module SweetTooth
  class SpendingOptionTest < Test::Unit::TestCase

    should "spending options should be listable" do
      @mock.expects(:get).once.returns(test_response(test_spending_option_array))
      c = SweetTooth::SpendingOption.all.items
      assert c.kind_of? Array
      assert c[0].kind_of? SweetTooth::SpendingOption
    end

  end
end
