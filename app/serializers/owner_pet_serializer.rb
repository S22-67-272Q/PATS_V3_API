class OwnerPetSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :date_of_birth, :gender

  attribute :animal_name do |object|
    object.animal.name
  end

  attribute :visits do |object|
    object.visits.chronological.map do |visit|
      OwnerVisitSerializer.new(visit).serializable_hash
    end
  end

end