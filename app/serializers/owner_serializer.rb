class OwnerSerializer
  include FastJsonapi::ObjectSerializer

  # This serializer is generated using the following command:
  # rails generate serializer Owner

  attributes :name, :street, :city, :state, :zip, :email

  attribute :phone do |object|
    ActionController::Base.helpers.number_to_phone(object.phone)
  end 

  #include the active pets owned by the owner
  attribute :active_pets do |object|
    object.pets.active.map do |pet|
      OwnerPetSerializer.new(pet).serializable_hash
    end
  end

  #include the inactive pets owned by the owner

  attribute :inactive_pets do |object|
    object.pets.inactive.map do |pet|
      OwnerPetSerializer.new(pet).serializable_hash
    end
  end

  #include the visits made by the owner

    attribute :visits do |object|
    object.visits.chronological.map do |visit|
      OwnerVisitSerializer.new(visit)
    end
  end

end
