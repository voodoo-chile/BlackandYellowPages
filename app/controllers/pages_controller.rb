class PagesController < ApplicationController
  def index
    @featured_news = NewsItem.find(:first, :conditions => {:featured => true})
    @latest_news = NewsItem.find(:all, :order => "created_at DESC", :limit => 4, :conditions => {:featured => false})
    @tags = Specialty.tag_counts_on(:tags)
  end

  def faq
  end

  def banners
  end

end
