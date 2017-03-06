require 'base64url'
require 'rbnacl/libsodium'
require 'manifoldco_signature/constants'

module ManifoldcoSignature
  class Verifier

    def initialize(master_key=MASTER_KEY)
      dec = Base64URL.decode(master_key)
      @master_key = RbNaCl::VerifyKey.new dec
    end

    def valid?(req)
      begin
        Signature.new(req).valid?(@master_key)
      rescue
        false
      end
    end

    def valid_signature?(signature)
      signature.valid?(@master_key)
    end
  end
end
