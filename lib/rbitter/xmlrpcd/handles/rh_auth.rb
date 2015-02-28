require_relative "base"

module RPCHandles
  module_function
  def auth
    if @@auth_pool.nil?
      @@auth_pool = Hash.new
    end

    @@auth_pool
  end
  
  class Authentication < BaseHandle::NoAuth
    attr_accessor :desc
    def initialize
      # should be also printed out to message buffer.
      # Just using 'puts' for dev
      @desc = RH_INFO.new("auth", 0.2, "nidev", "Rbitter XMLRPC authorization plugin")
      puts @desc.digest
    end

    def auth userid, password
      if Rbitter.env['auth'][0] == userid and Rbitter.env['auth'][1] == password
        token = "#{userid}%45#{userid.hash.abs.to_s}"
        # TODO: Time limit?
        RPCHandles.auth[token] = DateTime.now
        "#{token}"
      else
        ""
      end
    end

    def revoke_auth token
      if RPCHandles.auth.include?(token)
        RPCHandles.auth.delete(token)
      end
      ""
    end
  end
end