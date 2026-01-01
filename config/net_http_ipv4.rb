require "net/http"
require "resolv"

module Net
  class HTTP
    alias old_initialize initialize

    def initialize(address, *args)
      if address.is_a?(String) && address.include?(":")
        address = Resolv.getaddress(address)
      end
      old_initialize(address, *args)
    end
  end
end