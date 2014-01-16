require File.expand_path('../../test_helper', __FILE__)

module SweetTooth
  class RedemptionOptionTest < Test::Unit::TestCase

    should "redemption options should be listable" do
      @mock.expects(:get).once.returns(test_response(test_redemption_option_array))
      c = SweetTooth::RedemptionOption.all.items
      assert c.kind_of? Array
      assert c[0].kind_of? SweetTooth::RedemptionOption
    end

  end
end
