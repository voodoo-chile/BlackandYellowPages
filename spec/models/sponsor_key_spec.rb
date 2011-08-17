require 'spec_helper'
require 'cancan/matchers'

describe SponsorKey do
  it "has a hashed key" do
    key = Factory(:sponsor_key)
    key.key.should_not be_nil
  end
  
  it "has an expiration date" do
    key = Factory(:sponsor_key)
    key.expiration.should_not be_nil
  end
  
  describe "Guests" do
    it "cannot create invites" do
      u = Factory(:user)
      ability = Ability.new(u)
      ability.should_not be_able_to(:invite, User)
      u.roles = []
      ability = Ability.new(u)
      ability.should_not be_able_to(:invite, User)
    end
  end
  
  describe "Orphan" do
    it "cannot create invites" do
      u = Factory(:user)
      u.roles = ['orphan']
      ability = Ability.new(u)
      ability.should_not be_able_to(:invite, User)
    end
  end
  
  describe "Agorists and Admins" do
    %w(agorist admin).each do |role|
      it "with #{role} role can create invites" do
        u = Factory(:user)
        u.roles = [role]
        u.save
        ability = Ability.new(u)
        ability.should be_able_to(:invite, User)
        invite = u.generate_invite
        u.invites.should == [invite]
      end
    end
    
    it "cannot create more than 10 invites per day" do
      u = Factory(:user)
      10.times do
        u.generate_invite
      end
      lambda {
        u.generate_invite
      }.should_not change(SponsorKey, :count)
      first_invite = SponsorKey.first
      first_invite.created_at = 1.day.ago
      first_invite.save
      lambda {
        u.generate_invite
      }.should change(SponsorKey, :count).by(1)
    end
  end
  
  describe "Acceptance" do
    before(:each) do
    @invite = Factory(:sponsor_key)
    @params = {:username => 'testuser',
                  :email => 'test@blackandyellowpages.com',
                  :password => 'password',
                  :password_confirmation => 'password'}
    end
    
    it "assigns sponsor to new user" do
      sponsor = @invite.sponsor
      newuser = @invite.accept(@params)
      newuser.sponsor.should == sponsor     
    end
    
    it "is marked as used" do
      @invite.accept(@params)
      @invite.reload
      @invite.used.should == true
    end
    
    it "triggers sponsor trust links" do
      sponsor = @invite.sponsor
      newuser = @invite.accept(@params)
      sponsor.trust_links.first.trustee.should == newuser.id
      newuser.trust_links.first.trustee.should == sponsor.id
    end
    
    it "cannot reuse invitations" do
      @invite.used = true
      lambda {
        @invite.accept(@params)
      }.should_not change(User, :count)
    end
   
    it "cannot be accepted after expiration" do
      @invite.expiration = 1.week.ago
      lambda {
        @invite.accept(@params)
      }.should_not change(User, :count)
    end
  end
end
