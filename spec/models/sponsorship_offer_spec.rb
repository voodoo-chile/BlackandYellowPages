require 'spec_helper'

describe SponsorshipOffer do
  
  before(:each) do
    ActionMailer::Base.delivery_method = :test  
    ActionMailer::Base.perform_deliveries = true  
    ActionMailer::Base.deliveries = []  
  end  
    
  describe "Orphan" do
    it "can accept an offer" do
      user = Factory(:user)
      user.roles = ['orphan']
      offer = Factory(:sponsorship_offer)
      ability = Ability.new(user)
      ability.should_not be_able_to(:accept, offer)
      orphan = offer.user
      orphan.roles = ['orphan']
      ability = Ability.new(orphan)
      ability.should be_able_to(:accept, offer)
    end
  end
  
  it "delivers the offer to the orphan" do
      sponsor = Factory(:user)
      sponsor.roles = ['agorist']
      orphan = Factory(:user)
      orphan.roles = ['orphan']
      lambda {
        sponsor.adopt(orphan)
      }.should change(ActionMailer::Base.deliveries, :size).by(1)
      mail = ActionMailer::Base.deliveries.last
      mail.subject.should == "You have received a Black and Yellow Pages sponsorship offer"
      mail.to.should == [orphan.email]
  end  
    
  describe "Acceptance" do
    before(:each) do
      @offer = Factory(:sponsorship_offer)
      @sponsor = @offer.potential_sponsor
      @sponsor.roles = ['agorist']
      @sponsor.save
      @orphan = @offer.user
      @orphan.roles = ['orphan']
      @orphan.save
    end
  
    it "assigns the new sponsor" do
      @orphan.sponsor.should_not == @sponsor
      @offer.accept
      @orphan.reload
      @orphan.sponsor.should == @sponsor
    end
    
    it "changes the user role to agorist" do
      @orphan.roles.should == ['orphan']
      @offer.accept
      @orphan.reload
      @orphan.roles.should == ['agorist']
    end
    
    it "retains admin role if assigned" do
      @orphan.roles = ['orphan', 'admin']
      @orphan.save
      @offer.accept
      @orphan.reload
      @orphan.roles.should == ['agorist', 'admin']
    end
    
    it "rejects all other offers" do
      sponsor2 = Factory(:user)
      sponsor2.roles = ['agorist']
      sponsor3 = Factory(:user)
      sponsor3.roles = ['agorist']
      sponsor2.adopt(@orphan)
      sponsor3.adopt(@orphan)
      @offer.accept
      @offer.reload
      @offer.status.should == 'accepted'
      @orphan.adoption_offers.each do |o|
        o.status.should_not == 'pending'
      end
    end
    
    it "notifies the new sponsor" do
      lambda {
        @offer.accept
      }.should change(ActionMailer::Base.deliveries, :size).by(1)
      mail = ActionMailer::Base.deliveries.last
      mail.subject.should == "Your Black and Yellow Pages sponsorship offer has been accepted"
      mail.to.should == [@sponsor.email]
    end
    
    it "fails if the offer is expired" do
      @offer.expiration = 1.week.ago
      lambda {
        lambda {
          @offer.accept
        }.should_not change(@offer.user, :roles_mask)
      }.should_not change(@offer.user, :sponsor_id)
    end
  end
  
end
