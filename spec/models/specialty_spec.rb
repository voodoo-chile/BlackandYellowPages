require File.dirname(__FILE__) + '/../spec_helper'
require "cancan/matchers"

describe Specialty do

  describe "Validations" do
    it "has a valid email" do
      s = Specialty.new(:email => "test@blackandyellowpages.com")
      s.should be_valid
      s = Specialty.new(:email => "test")
      s.should_not be_valid
    end
  
    it "has a valid phone number" do
      s = Specialty.new(:phone => "12345")
      s.should_not be_valid
      s = Specialty.new(:phone => "(919) 555-1212")
      s.should be_valid
    end
  
    it "has a valid url" do
      s = Specialty.new(:url => "test.com")
      s.should_not be_valid
      s = Specialty.new(:url => "http://blackandyellowpages.com")
      s.should be_valid
    end
  end
  
  describe "Guests" do
    it "cannot manage any specialties" do
      s = Factory(:specialty)
      u = Factory(:user)
      ability = Ability.new(u)
      ability.should_not be_able_to(:update, s)
      u.roles = []
      ability = Ability.new(u)
      ability.should_not be_able_to(:update, s)
    end
  end
  
  describe "Agorist" do
    %w(agorist orphan).each do |role|
      it "with #{role} role can only manage thier own specialties" do
        s = Factory(:specialty)
        u = Factory(:user)
        s.user = u
        u.roles = [role]
        u.save
        ability = Ability.new(u)
        ability.should be_able_to(:manage, s)
        ability.should_not be_able_to(:manage, Specialty.new)
      end
    end
  end
  
  describe "Admin" do
    it "can manage any specialties" do
      u = Factory(:user)
      u.roles = ['admin']
      u.save
      s = Factory(:specialty, :user => u)
      ability = Ability.new(u)
      ability.should be_able_to(:manage, u)
      ability.should be_able_to(:manage, Specialty.new)
    end
  end
  
  describe "Geocoding" do
    it "fills in lat and long coordinates" do
      s = Specialty.create(:city => "Hermosa Beach", :region => "CA")
      s.latitude.should_not be_nil
      s.longitude.should_not be_nil
    end
  end
  
end
