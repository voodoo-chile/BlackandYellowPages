class TrustLink < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :trustee, :scope => :user_id, :message => "That trust link alread exists."
  
  def self.make_sponsor_links(sponsor, sponsoree)
    TrustLink.find_or_create_by_user_id_and_trustee(:user_id => sponsor.id, :trustee => sponsoree.id)
    TrustLink.find_or_create_by_user_id_and_trustee(:user_id => sponsoree.id, :trustee => sponsor.id)
  end
  
  def self.break_sponsor_links(sponsor, sponsoree)
    links = TrustLink.where(:user_id => sponsor.id, :trustee => sponsoree.id)
    links.each do |link|
      link.destroy
    end
    links = TrustLink.where(:user_id => sponsoree.id, :trustee => sponsor.id)
    links.each do |link|
      link.destroy
    end 
  end
  

  
end
