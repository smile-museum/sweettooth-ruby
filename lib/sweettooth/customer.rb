module SweetTooth
  class Customer < APIResource
    include SweetTooth::APIOperations::Create
    include SweetTooth::APIOperations::Delete
    include SweetTooth::APIOperations::Update
    include SweetTooth::APIOperations::List
  end
end
