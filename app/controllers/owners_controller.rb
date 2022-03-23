class OwnersController < ApplicationController
  # Start with swagger docs info
  swagger_controller :owners, "Owner Management"

  swagger_api :index do
    summary "Fetches all Owner objects"
    notes "This lists all the owners in PATS system"
    param :query, :active, :boolean, :optional, "Filter on whether or not the owner is active"
    param :query, :alphabetical, :boolean, :optional, "Order owners alphabetically by last name, first name"
  end

  swagger_api :show do
    summary "Shows one Owner object"
    param :path, :id, :integer, :required, "Owner ID"
    notes "This lists details of one owner in PATS"
    response :not_found
  end

  swagger_api :create do
    summary "Creates a new Owner"
    param :form, :first_name, :string, :required, "First name"
    param :form, :last_name, :string, :required, "Last name"
    param :form, :street, :string, :optional, "Street"
    param :form, :city, :string, :optional, "City"
    param :form, :state, :string, :optional, "State"
    param :form, :zip, :string, :optional, "Zip Code"
    param :form, :phone, :string, :optional, "Phone"
    param :form, :email, :string, :optional, "Email"
    param :form, :active, :boolean, :optional, "Active"
    param :form, :username, :string, :required, "Username"
    param :form, :password, :string, :required, "Password"
    param :form, :password_confirmation, :string, :required, "Password Confirmation"
    response :not_acceptable
  end

  swagger_api :update do
    summary "Updates an existing Owner"
    param :path, :id, :integer, :required, "Owner ID"
    param :form, :first_name, :string, :optional, "First name"
    param :form, :last_name, :string, :optional, "Last name"
    param :form, :street, :string, :optional, "Street"
    param :form, :city, :string, :optional, "City"
    param :form, :state, :string, :optional, "State"
    param :form, :zip, :string, :optional, "Zip Code"
    param :form, :phone, :string, :optional, "Phone"
    param :form, :email, :string, :optional, "Email"
    param :form, :active, :boolean, :optional, "Active"
    param :form, :username, :string, :optional, "Username"
    param :form, :password, :string, :optional, "Password"
    param :form, :password_confirmation, :string, :optional, "Password Confirmation"
    response :not_found
    response :not_acceptable
  end

  swagger_api :destroy do
    summary "Deletes an existing Owner"
    param :path, :id, :integer, :required, "Owner ID"
    response :not_found
    response :not_acceptable
  end

  # ----------------------
  # Actual controller code
  before_action :set_owner, only: [:show, :update, :destroy]

#  def index
#     @active_owners = Owner.active.alphabetical.all
#     render json: OwnerSerializer.new(@active_owners).serialized_json
#   end

  # Adding filtering and Ordering options using the params hash

  # As you might have guessed, params is an alias for the parameters . 
  # params comes from ActionController, which is accessed by your application 
  # via ApplicationController. 
  # Specifically, params refers to the parameters being passed to the controller
  #  via a GET or POST request.
  # Read more about Params: https://tinyurl.com/rails-params

def index
  @owners = Owner.all
  if params[:alphabetical].present? && params[:alphabetical] == "true"
    @owners = @owners.alphabetical
  end

  if(params[:active].present?)
    @owners = params[:active] == "true" ? @owners.active : @owners.inactive
  end
  render json: OwnerSerializer.new(@owners).serialized_json
end



  def show
    render json: OwnerSerializer.new(@owner).serialized_json
  end

  def create
    @owner = Owner.new(owner_params)
    @user = User.new(user_params)
    @user.role = "owner"
    if !@user.save
      render json: @user.errors, status: :unprocessable_entity
    else
      @owner.user_id = @user.id
      if @owner.save
        render json: @owner
      else
        render json: @owner.errors, status: :unprocessable_entity
      end      
    end
  end

  def update
    if @owner.update(owner_params)
      render json: @owner
    else
      render json: @owner.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @owner.destroy
    if !@owner.destroyed?
      render json: @owner.errors, status: :unprocessable_entity
    end
  end

  private
    def set_owner
      @owner = Owner.find(params[:id])
    end

    def owner_params
      params.permit(:first_name, :last_name, :street, :city, :state, :zip, :phone, :email, :active, :username, :password, :password_confirmation)
    end

    def user_params
      params.permit(:first_name, :last_name, :active, :username, :password, :password_confirmation)
    end

end