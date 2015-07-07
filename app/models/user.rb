class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable,  :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :lockable, :validatable
 
  #Relationships
  has_many :events
  has_many :rsvps

  #Validations
  validates_uniqueness_of :email

  def display_name
    if self.name.nil? or self.name.blank?
      return self.email
    else
      return self.name
    end
  end

  def to_s
    name || email
  end

  def flake_factor 
    reports = self.rsvps.reported
    flakes = reports.flaked

    unless reports.count == 0
      return flakes.count.to_f/reports.count.to_f
    else
      return nil
    end 
  end

  def reliability_factor
    flakiness = flake_factor
    if flakiness
      return 1.0 - flake_factor
    else
      return nil
    end
  end

end
