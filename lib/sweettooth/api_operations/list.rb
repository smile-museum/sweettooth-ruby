module SweetTooth
  module APIOperations
    module List
      module ClassMethods
        def all(filters={}, api_key=nil)
          response, api_key = SweetTooth.request(:get, url, api_key, filters)
          Util.convert_to_sweettooth_object(response, api_key)
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end
  end
end
