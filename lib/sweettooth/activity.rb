module SweetTooth
  class Activity < APIResource

    def self.class_name_plural
      'Activities'
    end

    include SweetTooth::APIOperations::Create
  end
end
