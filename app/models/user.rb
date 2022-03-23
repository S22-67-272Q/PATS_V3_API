class User < ApplicationRecord
  include AppHelpers::Activeable::InstanceMethods
  extend AppHelpers::Activeable::ClassMethods

  # Use built-in rails support for password protection
  has_secure_password
    
  # Relationships
  # has_many :notes
  has_one :owner

  # Validations
  # make sure required fields are present
  validates_presence_of :first_name, :last_name 
  validates :username, presence: true, uniqueness: { case_sensitive: false}
  validates_presence_of :password, :on => :create 
  validates_presence_of :password_confirmation, :on => :create 
  validates_confirmation_of :password, message: "does not match"
  validates_length_of :password, :minimum => 4, message: "must be at least 4 characters long", :allow_blank => true
  validates_inclusion_of :role, in: %w( vet assistant owner ), message: "is not recognized in the system"
  
  # Other methods
  # -----------------------------  
  def proper_name
    first_name + " " + last_name
  end
  
  def name
    last_name + ", " + first_name
  end

  # for use in authorizing with CanCan
  ROLES = [['Vet', :vet],['Assistant', :assistant],['Owner', :owner]]

  def role?(authorized_role)
    return false if role.nil?
    role.downcase.to_sym == authorized_role
  end
  
  # login by username
  def self.authenticate(username, password)
    find_by_username(username).try(:authenticate, password)
  end




  # So the general idea of the api_key is so that when someone sends a GET/POST/etc. request to your API, they will also need to provide the token in a header. 
  # Your API will then try to authenticate with that token and see what authorization that user has. 
  # This means that the api_key needs to be unique, so we will not be allowing users to change/create the api_key. 
  # Instead, we will be generating a random api_key for each user when the user is created. 
  # Therefore we add this new callback function in this model code for creating the api_key. 

  # callback that generates the API key
  before_create :generate_api_key

  def generate_api_key
    begin
      self.api_key = SecureRandom.hex
    end while User.exists?(api_key: self.api_key)
  end

end
