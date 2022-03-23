class TokenUserSerializer
  include FastJsonapi::ObjectSerializer
  set_type :user
  attributes :username, :api_key

end
