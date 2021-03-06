class NewsItem < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, :use => :slugged
  
  attr_accessible :user_id, :title, :body, :featured
  belongs_to :user
  
  def feature
    current_feature = NewsItem.find(:first, :conditions => {:featured => true})
    self.update_attributes(:featured => true)
    current_feature.update_attributes(:featured => false)
  end
end
