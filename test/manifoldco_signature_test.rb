require 'test_helper'
require 'rack'
require 'time'
require 'timecop'

DUMMY_MASTER_KEY = "PY7wu3q3-adYr9-0ES6CMRixup9OjO5iL7EFDFpolhk"

GOOD_REQ = Rack::Request.new(Rack::MockRequest.env_for("https://127.0.0.1:4567/v1/resources/2686c96868emyj61cgt2ma7vdntg4", {
  "REQUEST_METHOD" => "PUT",
  "HTTP_DATE" => "2017-03-05T23:53:08Z",
  "HTTP_HOST" => "127.0.0.1:4567",
  "CONTENT_TYPE" => "application/json",
  "CONTENT_LENGTH" => "143",
  "HTTP_X_SIGNED_HEADERS" => "host date content-type content-length",
  "HTTP_X_SIGNATURE" => "Nb9iJZVDFrcf8-dw7AsuSCPtdoxoAr61YVWQe-5b9z_YiuQW73wR7RRsDBPnrBMtXIg_h8yKWsr-ZNRgYbM7CA FzNbTkRjAGjkpwHUbAhjvLsIlAlL_M6EUh5E9OVEwXs qGR6iozBfLUCHbRywz1mHDdGYeqZ0JEcseV4KcwjEVeZtQN54odcJ1_QyZkmHacbQeHEai2-Aw9EF8-Ceh09Cg",
  :input => "{\"id\":\"2686c96868emyj61cgt2ma7vdntg4\",\"plan\":\"low\",\"product\":\"generators\",\"region\":\"aws::us-east-1\",\"user_id\":\"200e7aeg2kf2d6nud8jran3zxnz5j\"}\n"
}))

class ManifoldcoSignatureTest < Minitest::Test
  def setup
    back_then = Time.gm(2017, 3, 5, 23, 53, 8)
    Timecop.freeze(back_then)

    @verifier = ::ManifoldcoSignature::Verifier.new DUMMY_MASTER_KEY
  end

  def teardown
    Timecop.return
  end

  def test_that_it_has_a_version_number
    refute_nil ::ManifoldcoSignature::VERSION
  end

  def test_verifier_can_initialize
    ::ManifoldcoSignature::Verifier.new
  end

  def test_verifier_can_accept_good_signature
    assert @verifier.valid? GOOD_REQ
  end

  def test_verifier_can_reject_bad_signature
    req = Rack::Request.new(Rack::MockRequest.env_for("https://127.0.0.1:4567/v1/resources/2686c96868emyj61cgt2ma7vdntg4", {
      "REQUEST_METHOD" => "GET",
      "HTTP_DATE" => "2017-03-05T23:53:08Z",
      "HTTP_HOST" => "127.0.0.1:4567",
      "CONTENT_TYPE" => "application/json",
      "CONTENT_LENGTH" => "143",
      "HTTP_X_SIGNED_HEADERS" => "host date content-type content-length",
      "HTTP_X_SIGNATURE" => "Nb9iJZVDFrcf8-dw7AsuSCPtdoxoAr61YVWQe-5b9z_YiuQW73wR7RRsDBPnrBMtXIg_h8yKWsr-ZNRgYbM7CA FzNbTkRjAGjkpwHUbAhjvLsIlAlL_M6EUh5E9OVEwXs qGR6iozBfLUCHbRywz1mHDdGYeqZ0JEcseV4KcwjEVeZtQN54odcJ1_QyZkmHacbQeHEai2-Aw9EF8-Ceh09Cg",
      :input => "{\"id\":\"2686c96868emyj61cgt2ma7vdntg4\",\"plan\":\"low\",\"product\":\"generators\",\"region\":\"aws::us-east-1\",\"user_id\":\"200e7aeg2kf2d6nud8jran3zxnz5j\"}\n"
    }))

    refute @verifier.valid? req
  end

  def test_verifier_can_reject_old_signature
    way_back_then = Time.gm(2015, 3, 5, 23, 53, 8)
    Timecop.freeze(way_back_then)

    refute @verifier.valid? GOOD_REQ
  end
end
