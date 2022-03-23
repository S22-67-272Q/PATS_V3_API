class ApplicationController < ActionController::API

   # Code for handling errors a little better
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_response

  def render_unprocessable_entity_response(exception)
    render json: exception.record.errors, status: :unprocessable_entity
  end

  def render_not_found_response(exception)
    render json: { error: exception.message }, status: :not_found
  end


  # Adding authentication and making sure every controller uses it.

  # We start by adding in these modules that already exist in Rails. 
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_with_token, except: [:token]

  def authenticate_with_token
    authenticate_user_from_token || render_unauthorized
  end

  def authenticate_user_from_token
    authenticate_with_http_token do |token, options|
      @current_user = User.find_by(api_key: token)
    end
  end

  def render_unauthorized(realm = "Application")
    self.headers["WWW-Authenticate"] = %(Token realm="#{realm.gsub(/"/, "")}")
    render json: {error: "Bad Credentials"}, status: :unauthorized
  end













  include ActionController::HttpAuthentication::Basic::ControllerMethods

  # A method to handle initial authentication
  # We are using something called Basic Http Authentication which is provided by rails,
  # that authenticates with username and password. 
  # This /token endpoint will not be authenticated with the api_key, but rather with email and password.
  #  As mentioned before, this endpoint will return the user JSON, which contains the api_key. 
  # Once someone enters their username/password and uses this endpoint to retrieve their api_key, 
  # they can then use the api_key to authenticate with all the other endpoints.
  def token
    authenticate_username_password || render_unauthorized
  end

  def authenticate_username_password
    authenticate_or_request_with_http_basic do |username, password|
      user = User.authenticate(username, password)
      if user
        render json: TokenUserSerializer.new(user).serialized_json

      end
    end
  end

end
