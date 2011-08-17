require File.dirname(__FILE__) + '/../spec_helper'
require "cancan/matchers"


describe User do

  # Setup ActionMailer for delivery tests
  before(:each) do
    ActionMailer::Base.delivery_method = :test  
    ActionMailer::Base.perform_deliveries = true  
    ActionMailer::Base.deliveries = []  
  end  
  
  # Expected behavior: a user should have a username, valid email, and password
  describe "Validations" do
    subject { User.new}
    
    %w(username email password password_confirmation).each do |attr|
      it "requires #{attr}" do
        should_not be_valid
        subject.errors[attr.to_sym].should_not be_nil
      end
      
    end
  end

  describe "Contact Information" do
    subject { User.new }
    
    it "has one Contact" do
      should respond_to(:contact)
    end
    
    it "can retrieve a Contact" do
      c = Factory(:contact)
      u = c.user
      u.contact.should == c
    end
    
    it "allows creation of a Contact" do
      u = Factory(:user)
      lambda {
        u.create_contact
      }.should change(Contact, :count).by(1)
    end
    
  end
  
  describe "Specialties" do
    it "has many Specialties" do
      should respond_to(:specialties)
    end
    
    it "can retrieve Specialties" do
      u = Factory(:user)
      s = []
      3.times do |i|
        s[i] = Factory(:specialty, :user_id => u.id)
      end
      u.specialties.should == s
    end
    
    it "allows creation of a Specialty" do
      u = Factory(:user)
      lambda {
        u.specialties.create
      }.should change(Specialty, :count).by(1)
    end
  end  
  
  describe TrustLink do
    it "has many TrustLinks" do
      should respond_to(:trust_links)
    end
    
    it "can retrieve a TrustLink" do
      t = Factory(:trust_link)
      u = t.user
      u.trust_links.should == [t]
    end
    
    it "allows creation of a TrustLink" do
      u = Factory(:user)
      lambda {
        u.trust_links.create
      }.should change(TrustLink, :count).by(1)
    end
  end
    
  describe "Invites" do
    it "has many invites" do
      should respond_to(:invites)
    end
    
    it "can retrieve an invite" do
      i = Factory(:sponsor_key)
      u = i.sponsor
      u.invites.should == [i]
    end
    
    it "allows creation of an invite" do
      u = Factory(:user)
      lambda {
        u.invites.create
      }.should change(SponsorKey, :count).by(1)
    end
  end
 
  describe SponsorshipOffer do
    it "has many offers" do
      should respond_to(:adoption_offers)
    end
    
    it "has many requests" do
      should respond_to(:adoption_requests)
    end
    
    it "can retrieve a request" do
      s = Factory(:sponsorship_offer)
      u = s.potential_sponsor
      u.adoption_requests.should == [s]
    end
    
    it "can retrieve an offer" do
      s = Factory(:sponsorship_offer)
      u = s.user
      u.adoption_offers.should == [s]
    end
  end
   
  describe "Roles" do
    
    %w(guest agorist orphan admin).each do |role|
      it "can be assigned #{role} role" do 
        u = Factory(:user)
        u.roles = [role]
        u.save
        u.should be_role(role.to_sym)
      end
    end
    
    it "can be assigned multiple roles" do
      u = Factory(:user)
      u.roles = ["agorist", "admin"]
      u.save
      u.should be_role(:admin)
      u.should be_role(:agorist)
    end
    
  end
  
  describe "Guests" do
    it "cannot update any users" do
      u = Factory(:user)
      ability = Ability.new(u)
      ability.should_not be_able_to(:update, u)
    end
  end
  
  describe "Agorist" do
    %w(agorist orphan).each do |role|
      it "with #{role} role can only update themselves" do
        u = Factory(:user)
        u.roles = [role]
        u.save
        ability = Ability.new(u)
        ability.should be_able_to(:update, u)
        ability.should_not be_able_to(:update, User.new)
      end
    end
    
    it "can adopt orphans" do
      user1 = Factory(:user)
      user1.roles = ['agorist']
      user2 = Factory(:user)
      user2.roles = ['agorist']
      orphan = Factory(:user)
      orphan.roles = ['orphan']
      ability = Ability.new(user1)
      ability.should_not be_able_to(:adopt, user2)
      ability.should be_able_to(:adopt, orphan)
    end
    
    it "cannot adopt orphans in the user lineage" do
      orphan = Factory(:user)
      orphan.roles = ['orphan']
      user = Factory(:user)
      user.roles = ['agorist']
      user.sponsor_id = orphan.id
      user.save
      ability = Ability.new(user)
      ability.should_not be_able_to(:adopt, orphan)
    end
  end
  
  describe "Admin" do
    it "can update any users" do
      u = Factory(:user)
      u.roles = ['admin']
      u.save
      ability = Ability.new(u)
      ability.should be_able_to(:update, u)
      ability.should be_able_to(:update, User.new)
    end
  end
  
  describe "Newly Created" do
    it "is not active" do
      u = Factory(:user)
      u.should_not be_active
    end
    
    it "sends an activation email" do
      u = Factory(:user)
      ActionMailer::Base.deliveries.size.should == 1
      mail = ActionMailer::Base.deliveries.first
      mail.subject.should == "Activation Instructions"
    end
    
    it "has guest role" do
      u = Factory(:user)
      u.should be_role(:guest)
    end
  end
  
  describe "Resending Activation Email" do
    it "does not send an email if the user is already active" do
      u = Factory(:user)
      ActionMailer::Base.deliveries.size.should == 1
      u.activate!(u.perishable_token)
      u.should be_active
      u.resend_activation
      ActionMailer::Base.deliveries.size.should == 1
      u.errors[:base].should_not be_empty      
    end
    
    it "changes the token and sends new instructions" do
      u = Factory(:user)
      token = u.perishable_token
      lambda {
        u.resend_activation
      }.should change(ActionMailer::Base.deliveries, :size).by(1)
      u.perishable_token.should_not == token
    end
  end
  
  describe "Activation" do
    it "validates the perishable_token" do
      u = Factory(:user)
      u.activate!("abcde")
      u.should_not be_active
      u.errors[:base].should_not be_empty
    end
  end
  
  describe "New Activation" do
    before do
      @u = Factory(:user)
      @u.activate!(@u.perishable_token)
    end
    
    it "sets User to active" do
      @u.should be_active
    end
    
    it "assigns agorist role" do
      @u.should be_role(:agorist)
    end
  end
  
  describe "Password Reset request" do
    before do
      @u = Factory(:user)
      @u.activate!(@u.perishable_token)
      @token = @u.perishable_token
    end
    
    it "does not send an email if the User is not found" do
      invalid_email = "invalid@test.com"
      lambda {
        User.password_reset_request(invalid_email)
      }.should_not change(ActionMailer::Base.deliveries, :size)
    end
    
    it "resets the perishable_token" do
      User.password_reset_request(@u.email)
      @u.reload
      @u.perishable_token.should_not == @token
    end
    
    it "sends a password reset email" do
      User.password_reset_request(@u.email)
      ActionMailer::Base.deliveries.size.should == 2
      mail = ActionMailer::Base.deliveries.last
      mail.subject.should == "Password Reset Instructions"
      mail.to.should == [@u.email]
    end
    
  end
  
  describe "Orphaning" do
    it "changes User status to orphan" do
      u = Factory(:user)
      u.orphan
      u.sponsor_id.should == 0
      u.should be_role(:orphan)
      u.should_not be_role(:agorist)
    end
    
    it "retains admin role" do
      u = Factory(:user)
      u.roles = ['agorist', 'admin']
      u.orphan
      u.should be_role(:admin)
      u.should be_role(:orphan)
    end
    
    it "sends notification to the user" do
      u = Factory(:user)
      lambda {
        u.orphan
      }.should change(ActionMailer::Base.deliveries, :size).by(1)
      mail = ActionMailer::Base.deliveries.last
      mail.subject.should == "Your Black and Yellow Pages sponsor has withdrawn"
      mail.to.should == [u.email]
    end 
    
    it "can only be done by the sponsor" do
      s = Factory(:user)
      s.roles = ['agorist']
      u = Factory(:user, :sponsor_id => s.id)
      u.roles = ['agorist']
      ability = Ability.new(s)
      ability.should be_able_to(:orphan, u)
      ability = Ability.new(u)
      ability.should_not be_able_to(:orphan, s)
    end
  end
  
  describe "Adopting" do
    it "creates a new sponsorship offer" do
      sponsor = Factory(:user)
      sponsor.roles = ['agorist']
      orphan = Factory(:user)
      orphan.roles = ['orphan']
      lambda {
        @offer = sponsor.adopt(orphan)
      }.should change(SponsorshipOffer, :count).by(1)
      @offer.potential_sponsor.should == sponsor
      @offer.user.should == orphan
    end
  end

  it "has degrees of trust from other users" do
    userA = Factory(:user)
    userB = Factory(:user, :sponsor_id => userA.id)
    TrustLink.make_sponsor_links(userA, userB)
    userC = Factory(:user, :sponsor_id => userB.id)
    TrustLink.make_sponsor_links(userB, userC)
    userD = Factory(:user, :sponsor_id => userA.id)
    TrustLink.make_sponsor_links(userA, userD)
    userE = Factory(:user, :sponsor_id => 0)
    TrustLink.create(:user_id => userD.id, :trustee => userB.id)
    userC.degrees_of_trust(userD).should == 3
    userD.degrees_of_trust(userC).should == 2
    userE.degrees_of_trust(userA).should == 'infinite'
  end
  
  
end
