class PetSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :date_of_birth
  
  attribute :animal do |object|
    object.animal.name.downcase
  end
  
  attribute :gender do |object|
    object.female ? "female" : "male"
  end

  attribute :current_weight do |object|
    object.visits.chronological.first.weight
  end

  # Fetch pets'owner details
  # we can include only the first and last names, only
  # attribute :owner do |object|
  #   object.owner.proper_name
  # end

  #  A better version would be where we can use the OwnerSerializer to get more details
  # attribute :owner do |object|
  #   OwnerSerializer.new(object.owner)
  # end

  # But this is problematic: Error. Completed 500 Internal Server Error 
  #  SystemStackError (stack level too deep)
  # THINK OF THE RECURSION HERE: PET CALLS OWNERS, AND OWNERS CALL PETS
  
# TO FIX THIS:
# WE CREATE A SPECIAL SERIALIZER FOR OWNERS CALLED PetOwnerSerializer
# WHERE WE INCLUDE SPECIFIC DETAILS AND MAKE SURE TO
# NOT TO CONSIDER ANY PET DETAILS. This serializer would be called each time we would like to include 
#  the owner's details in the Pet json representation.
  attribute :owner do |object|
    PetOwnerSerializer.new(object.owner).serializable_hash
  end

  # Fetch pet's visits details
  attribute :visits do |object|
    object.visits.chronological.map do |visit|
      PetVisitSerializer.new(visit).serializable_hash
    end
  end


end
