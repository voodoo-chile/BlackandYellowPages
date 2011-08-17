class SponsorKey < ActiveRecord::Base
  belongs_to :sponsor, :class_name => 'User', :foreign_key => 'sponsor_id'
  belongs_to :user
  
  before_create :generate_key
  before_create :set_expiration
  
  def accept(params)
    if self.used != true && self.expiration > Date.today
      user = User.new(params)
      user.sponsor_id = self.sponsor_id
      if user.save
        self.user_id = user.id
        self.used = true
        self.save
        TrustLink.make_sponsor_links(user, user.sponsor)
      end
      user
    else
      self.errors.add(:base, "Sorry, that invitation is not valid.")
    end
  end
  
  def valid_invite?
    if self.expiration > Date.today
      true
    end
  end
  
  private
  
  def generate_key
    self.key = SecureRandom.hex(10)
  end
  
  def set_expiration
    self.expiration = 1.week.from_now
  end
  
end
