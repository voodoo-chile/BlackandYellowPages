require 'spec_helper'
require 'cancan/matchers'

describe TrustLink do
  it "creates a two-way trust link with a sponsor" do
    sponsor = Factory(:user)
    sponsoree = Factory(:user)
    TrustLink.make_sponsor_links(sponsor, sponsoree)
    sponsor.trust_links.first.trustee.should == sponsoree.id
    sponsoree.trust_links.first.trustee.should == sponsor.id
  end
  
  it "is unique" do
    user  = Factory(:user)
    trustee = Factory(:user)
    lambda {
      TrustLink.create(:user_id => user.id, :trustee => trustee.id)
    }.should change(TrustLink, :count).by(1)
    lambda {
      TrustLink.create(:user_id => user.id, :trustee => trustee.id)
    }.should_not change(TrustLink, :count)
  end
  
  it "can only be destroyed by the user" do
    user = Factory(:user)
    user.roles = ['agorist']
    trustee = Factory(:user)
    user.roles = ['agorist']
    link = TrustLink.create(:user_id => user.id, :trustee => trustee.id)
    ability = Ability.new(user)
    ability.should be_able_to(:destroy, link)
    ability = Ability.new(trustee)
    ability.should_not be_able_to(:destroy, link)
  end
  
  
end
