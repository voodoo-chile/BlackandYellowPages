class SponsorshipOffer < ActiveRecord::Base
  belongs_to :potential_sponsor, :class_name => 'User', :foreign_key => 'sponsor_id'
  belongs_to :user
  
  before_create :set_expiration
  after_create :send_offer
  
  def accept
    if self.expiration > Date.today
      self.user.sponsor_id = self.potential_sponsor.id
      if self.user.roles.include?('admin')
        self.user.roles = ['agorist', 'admin']
      else
        self.user.roles = ['agorist']
      end
      if self.user.save
        @user = self.user
        TrustLink.make_sponsor_links(@user.sponsor, @user)
        Notifier.offer_accepted(self).deliver
        self.status = 'accepted'
        self.save
        self.user.adoption_offers.each do |o|
          if o.status == 'pending'
            o.reject
          end
        end
      end
    else
      self.errors.add(:base, "Sorry, that offer has expired.")
    end
  end
  
  def reject
    self.status = 'rejected'
    self.save
    Notifier.offer_rejected(self).deliver
  end
  
  def expire
    self.status = 'expired'
    self.save
  end
  
  private
  
  def set_expiration
    self.expiration = 1.week.from_now
  end
  
  def send_offer
    Notifier.adoption_offer(self.user, self.potential_sponsor).deliver
  end
  
end
