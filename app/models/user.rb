class User < ActiveRecord::Base
  acts_as_authentic
  attr_accessible :username, :email, :roles, :password, :password_confirmation, :sponsor_id, :contact_attributes
  
  has_one :contact
  accepts_nested_attributes_for :contact, :allow_destroy => true
  
  has_many :sponsorees, :class_name => 'User', :foreign_key => 'sponsor_id'
  belongs_to :sponsor, :class_name => 'User', :foreign_key => 'sponsor_id'
  
  has_many :specialties
  accepts_nested_attributes_for :specialties, :allow_destroy => true
  
  has_many :trust_links
  accepts_nested_attributes_for :trust_links, :allow_destroy => true
  
  has_many :invites, :class_name => 'SponsorKey', :foreign_key => 'sponsor_id'
  
  has_many :adoption_requests, :class_name => 'SponsorshipOffer', :foreign_key => 'sponsor_id'
  has_many :adoption_offers, :class_name => 'SponsorshipOffer', :foreign_key => 'user_id'
  
  has_one :sponsor_key
  
  has_many :news_items
  
  validates_uniqueness_of :username
  
  before_create :set_guest_role
  after_create :deliver_activation_instructions!

  
  # Creates a bitwise mask for assigning user roles. Roles can be assigned to users by User.roles = ['rolename']
  scope :with_role, lambda { |role| where("roles_mask & #{2**ROLES.index(role.to_s)} > 0") }
  
  ROLES = %w[guest agorist orphan admin]
  
  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end
  
  def roles
    ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }
  end
  
  def role?(role)
    roles.include? role.to_s
  end
  
  # Checks the activation token, activates user
  def activate!(token)
    if token == self.perishable_token
      self.active = true
      self.roles = ['agorist']
      save
    else
      self.errors.add(:base, "Sorry, that activation token is invalid. Please check the activation email and try again.")
    end
  end
  
  def resend_activation
    deliver_activation_instructions!
  end
  
  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.password_reset(self).deliver
  end
  
  def generate_invite
    invite_count = SponsorKey.find(:all, :conditions => ["created_at > ?", 1.day.ago]).count
    if invite_count < 10
      SponsorKey.create(:sponsor_id => self.id)
    else
      self.errors.add(:base, "Sorry, you can only generate 10 invitations per day.")
    end
  end
  
  def orphan
    self.sponsor_id = 0
    if self.roles.include?('admin')
      self.roles = ['orphan', 'admin']
    else
      self.roles = ['orphan']
    end
    save
    Notifier.orphaned(self).deliver
  end
  
  def adopt(orphan)
    SponsorshipOffer.create(:sponsor_id => self.id, :user_id => orphan.id)
  end
  
  def no_relationship?(user)
    if user.sponsor_id == self.id
      false
    elsif user.sponsor_id == 0 || user.sponsor_id == 1
      true
    else
      self.no_relationship?(user.sponsor)
    end
  end
  
  def degrees_of_trust(trustee)
    @history = []
    @degrees_of_trust = 0
    @trustee_id = trustee.id
    @links = self.trust_links
    count_trust_links(@links)
  end
  
  
  
  private
  
  def deliver_activation_instructions!
    if !self.active?
      reset_perishable_token!
      Notifier.activation_instructions(self).deliver
    else
      self.errors.add(:base, "That is already an active user.")
    end
  end
  
  def set_guest_role
    self.roles = ['guest']
  end
  
  def count_trust_links(set)
    @this_set = set
    @next_set = []
    @degrees_of_trust += 1
    @this_set.each do |l|
      if l.trustee == @trustee_id
        return @degrees_of_trust
      else
        @history << l.user_id unless @history.detect {|h| h==l.user_id}
        unless @history.detect { |h| h==l.trustee }
          @middle_set = TrustLink.find_all_by_user_id(l.trustee)
          @middle_set.each do |m|
            @next_set << m
          end
        end
      end
    end
    if @next_set == []
      return "infinite"
    else
      count_trust_links(@next_set)
    end
  end
  
end
