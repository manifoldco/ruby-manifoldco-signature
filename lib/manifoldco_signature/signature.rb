require 'base64url'
require 'date'
require 'rbnacl/libsodium'
require 'manifoldco_signature/constants'

module ManifoldcoSignature

  class Signature

    def initialize(req)
      sig = req.env['HTTP_X_SIGNATURE'].split
      @signature = Base64URL.decode(sig[0])
      @public_key_raw = Base64URL.decode(sig[1])
      @public_key = RbNaCl::VerifyKey.new @public_key_raw
      @endorsement = Base64URL.decode(sig[2])

      @message = canonize(req)
      @req_time = DateTime.rfc3339(req.env['HTTP_DATE'])
    end

    def valid?(master_key)
      good_signature?(master_key) && valid_time?
    end

    def good_signature?(master_key)
      begin
        master_key.verify(@endorsement, @public_key_raw) &&
          @public_key.verify(@signature, @message)
      rescue
        false
      end
    end

    def valid_time?
      now = DateTime.now()
      ((now - @req_time) * 24 * 60).abs <= PERMITTED_SKEW_IN_MINUTES
    end

    protected
    def canonize(req)

      msg = "#{req.request_method.downcase} #{req.path}"

      if !req.query_string.empty?
        msg += '?' + req.query_string.split('&').sort!.join('&')
      end
      msg += "\n"

      headers = req.env['HTTP_X_SIGNED_HEADERS'].split
      headers << 'x-signed-headers'
      headers.each do |header|
        if header.downcase == 'content-type'
          value = req.content_type
        elsif header.downcase == 'content-length'
          value = req.content_length
        else
          value = req.env["HTTP_#{header.upcase.gsub(/-/, '_')}"]
        end
        msg += "#{header.downcase}: #{value}\n"
      end

      # Rewind the body before and after reading, in case anyone else has read
      # it before us, or anyone else will read it after us.
      req.body.rewind
      msg += req.body.read
      req.body.rewind

      msg
    end
  end

end
