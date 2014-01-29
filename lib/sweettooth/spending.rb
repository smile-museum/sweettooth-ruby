module SweetTooth
  class Spending < APIResource
    include SweetTooth::APIOperations::Create

    def cancel()
      response, api_key = SweetTooth.request(:post, cancel_url, @api_key)
      refresh_from(response, api_key)
      self
    end

    def cancel_url
      url + '/cancel'
    end
  end
end
