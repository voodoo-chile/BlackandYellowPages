require 'spec_helper'
require "cancan/matchers"

describe Contact do
  context "Associations" do
    
    it "belongs to User" do
      should respond_to(:user)
    end
    
  end
  
  describe "Guests" do
    it "cannot update any contacts" do
      u = Factory(:user)
      ability = Ability.new(u)
      ability.should_not be_able_to(:update, Contact.new)
    end
  end
  
  describe "Owner" do
    %w(agorist orphan).each do |role|
      it "with #{role} role can only update information on owned contacts" do
        u = Factory(:user)
        u.roles = [role]
        u.save
        ability = Ability.new(u)
        ability.should be_able_to(:update, Contact.new(:user => u))
        ability.should_not be_able_to(:update, Contact.new)
      end
    end
  end
  
  describe "Admin" do
    it "can update any contacts" do
      u = Factory(:user)
      u.roles = ['admin']
      u.save
      ability = Ability.new(u)
      ability.should be_able_to(:update, Contact.new(:user => u))
      ability.should be_able_to(:update, Contact.new)
    end
  end
  
end
