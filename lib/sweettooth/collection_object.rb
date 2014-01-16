module SweetTooth
  class CollectionObject < SweetToothObject

    def [](k)
      case k
      when String, Symbol
        super
      else
        raise ArgumentError.new("You tried to access the #{k.inspect} index, but CollectionObject types only support String keys. (HINT: List calls return an object with a 'items' (which is the items array). You likely want to call #items[#{k.inspect}])")
      end
    end

    def each(&blk)
      self.items.each(&blk)
    end

    def retrieve(id, api_key=nil)
      api_key ||= @api_key
      response, api_key = SweetTooth.request(:get,"#{url}/#{CGI.escape(id)}", api_key)
      Util.convert_to_sweettooth_object(response, api_key)
    end

    def create(params={}, api_key=nil)
      api_key ||= @api_key
      response, api_key = SweetTooth.request(:post, url, api_key, params)
      Util.convert_to_sweettooth_object(response, api_key)
    end

    def all(params={}, api_key=nil)
      api_key ||= @api_key
      response, api_key = SweetTooth.request(:get, url, api_key, params)
      Util.convert_to_sweettooth_object(response, api_key)
    end
  end
end
