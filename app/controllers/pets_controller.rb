class PetsController < ApplicationController
    # Start with swagger docs info
  swagger_controller :pets, "Pet Management"

  swagger_api :index do
    summary "Fetches all Pet objects"
    notes "This lists all the pets in PATS system"
  end

  swagger_api :show do
    summary "Shows one Pet object"
    param :path, :id, :integer, :required, "Pet ID"
    notes "This lists details of one pet in PATS"
    response :not_found
  end

  swagger_api :create do
    summary "Creates a new Pet"
    param :form, :name, :string, :required, "Name"
    param :form, :animal_id, :integer, :required, "Animal ID"
    param :form, :owner_id, :integer, :required, "Owner ID"
    param :form, :female, :boolean, :optional, "Female"
    param :form, :date_of_birth, :date, :optional, "Date of Birth"
    param :form, :active, :boolean, :optional, "Active"
    response :not_acceptable
  end

  swagger_api :update do
    summary "Updates an existing Pet"
    param :path, :id, :integer, :required, "Pet ID"
    param :form, :name, :string, :optional, "Name"
    param :form, :animal_id, :integer, :optional, "Animal ID"
    param :form, :owner_id, :integer, :optional, "Owner ID"
    param :form, :female, :boolean, :optional, "Female"
    param :form, :date_of_birth, :date, :optional, "Date of Birth"
    param :form, :active, :boolean, :optional, "Active"
    response :not_found
    response :not_acceptable
  end

  swagger_api :destroy do
    summary "Deletes an existing Pet"
    param :path, :id, :integer, :required, "Pet ID"
    response :not_found
    response :not_acceptable
  end

  # ----------------------
  # Actual controller code

  before_action :set_pet, only: [:show, :update, :destroy]

  # Original index action
  # def index
  #   @active_pets = Pet.active.alphabetical.all
  #   render json: PetSerializer.new(@active_pets).serializable_hash
  # end

  # Adding the Filtering and ordering options
  # def index
  #   @pets = Pet.all
  #   if params[:alphabetical].present? && params[:alphabetical] == "true"
  #     @pets = @pets.alphabetical
  #   end
  
  #   if(params[:active].present?)
  #     @pets = params[:active] == "true" ? @pets.active : @pets.inactive
  #   end
  #   render json: PetSerializer.new(@pets).serialized_json
  # end

  #  A better more general version: Using the filterables and orderables modules
  #  available under lib/filters
  include Filterable
  include Orderable
  
  BOOLEAN_FILTERING_PARAMS = [[:active, :inactive], [:females, :males]]  # You can see here that there is a pairing of scopes that are boolean:
  PARAM_FILTERING_PARAMS = [:for_owner, :by_animal, :born_before]
  ORDERING_PARAMS = [:alphabetical]

  def index
    @pets = boolean_filter(Pet.all, BOOLEAN_FILTERING_PARAMS)
    @pets = param_filter(@pets, PARAM_FILTERING_PARAMS)
    @pets = order(@pets, ORDERING_PARAMS)
    render json: PetSerializer.new(@pets).serialized_json
  end
  
 
  def show
    render json: PetSerializer.new(@pet).serializable_hash
  end

  def create
    @pet = Pet.new(pet_params)
    if @pet.save
      render json: @pet
    else
      render json: @pet.errors, status: :unprocessable_entity
    end
  end

  def update
    if @pet.update(pet_params)
      render json: @pet
    else
      render json: @pet.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @pet.destroy
    if !@pet.destroyed
      render json: @pet.errors, status: :unprocessable_entity
    end
  end

  private
  def set_pet
    @pet = Pet.find(params[:id])
  end

  def pet_params
    params.permit(:name, :animal_id, :owner_id, :female, :date_of_birth, :active)
  end

end
